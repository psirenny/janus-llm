from math import ceil
from pathlib import Path
from typing import List

from langchain.schema.language_model import BaseLanguageModel

from ..utils.logger import create_logger
from .block import CodeBlock
from .file import FileManager
from .node import NodeType

log = create_logger(__name__)


class TokenLimitError(Exception):
    """An exception raised when the token limit is exceeded and the code cannot be
    split into smaller blocks.
    """

    pass


class Splitter(FileManager):
    """A class for splitting code into functional blocks to prompt with for
    transcoding.
    """

    def __init__(
        self,
        language: str,
        model: BaseLanguageModel,
        max_tokens: int = 4096,
        use_placeholders: bool = True,
    ):
        """
        Arguments:
            max_tokens: The maximum number of tokens to use for each functional block.
            model: The name of the model to use for translation.
        """
        super().__init__(language=language)
        self.model = model
        self.use_placeholders = use_placeholders

        # Divide max_tokens by 3 because we want to leave just as much space for the
        # prompt as for the translated code.
        self.max_tokens: int = max_tokens // 3

    def split(self, file: Path | str) -> CodeBlock:
        """Split the given file into functional code blocks.

        Arguments:
            file: The file to split into functional blocks.

        Returns:
            A `CodeBlock` made up of nested `CodeBlock`s.
        """
        path = Path(file)
        code = path.read_text()

        root = self._get_ast(code)
        self._set_identifiers(root, path)

        self._recurse_split(root)
        log.info(f"[{root.name}] CodeBlock Structure:\n{root.tree_str()}")

        return root

    def _get_ast(self, code: str | bytes) -> CodeBlock:
        raise NotImplementedError()

    def _set_identifiers(self, root: CodeBlock, path: Path):
        seen_ids = 0
        queue = [root]
        while queue:
            node = queue.pop(0)  # BFS order to keep lower IDs toward the root
            node.id = f"child_{seen_ids}"
            seen_ids += 1
            node.name = f"{path.name}:{node.id}"
            queue.extend(node.children)

    def _recurse_split(self, node: CodeBlock):
        """Recursively split the code into functional blocks.

        Arguments:
            node: The current node in the tree.
        """
        # If the text at the function input is less than the max tokens, then
        #  we can just return it as a CodeBlock with no children.
        if node.tokens <= self.max_tokens:
            node.children = []
            return

        node.complete = False

        # Consolidate nodes into groups, and then merge each group into a new node
        node_groups = self._consolidate_nodes(node.children)
        node.children = list(map(self.merge_nodes, node_groups))

        # If not using placeholders, simply recurse for every child and delete
        #  this node's text and tokens
        if not self.use_placeholders:
            if not node.children:
                log.error(f"[{node.name}] Childless node too long for context!")
            for child in node.children:
                self._recurse_split(child)
            node.text = None
            node.tokens = 0
            return

        text_chunks = [c.complete_placeholder for c in node.children]
        node.text = "".join(text_chunks)
        node.tokens = self._count_tokens(node.text)

        # If the text is still too long even with every child replaced with
        #  placeholders, there's no reason to bother with placeholders at all
        if node.tokens > self.max_tokens:
            node.text = None
            node.tokens = 0
            return

        sorted_indices: List[int] = sorted(
            range(len(node.children)),
            key=lambda idx: node.children[idx].tokens,
        )

        merged_child_indices = set()
        for idx in sorted_indices:
            child = node.children[idx]
            text_chunks[idx] = child.complete_text
            text = "".join(text_chunks)
            tokens = self._count_tokens(text)
            if tokens > self.max_tokens:
                break

            node.text = text
            node.tokens = tokens
            merged_child_indices.add(idx)

        # Remove all merged children from the child list
        node.children = [
            child for i, child in enumerate(node.children)
            if i not in merged_child_indices
        ]

        for child in node.children:
            self._recurse_split(child)

    def _consolidate_nodes(self, nodes: List[CodeBlock]) -> List[List[CodeBlock]]:
        """Consolidate a list of tree_sitter nodes into groups. Each group should fit
        into the context window, with the exception of single-node groups which may be
        too long to fit on their own. This ensures that nodes with many many short
        children are not translated one child at a time, instead packing as many children
        adjacent snippets as possible into context.

        This function attempts to efficiently pack nodes, but is not optimal.

        Arguments:
            nodes: A list of tree_sitter nodes

        Returns:
            A list of lists. Each list consists of one or more nodes. This structure is
            ordered such that, were it flattened, all nodes would be sorted according to
            appearance in the original file.
        """
        nodes = sorted(nodes)
        text_chunks = [child.text for child in nodes]
        lengths = [node.tokens for node in nodes]

        # Estimate the length of each adjacent pair were they merged
        adj_sums = [lengths[i] + lengths[i + 1] for i in range(len(lengths) - 1)]

        groups = [[n] for n in nodes]
        while len(groups) > 1 and min(adj_sums) <= self.max_tokens:
            # Get the indices of the adjacent nodes that would result in the
            #  smallest possible merged snippet
            i0 = int(min(range(len(adj_sums)), key=adj_sums.__getitem__))
            i1 = i0 + 1

            # Recalculate the length. We can't simply use the adj_sum, because
            #  it is an underestimate due to the adjoining suffix/prefix.
            #  In testing, the length of a merged pair is between 2 and 3 tokens
            #  longer than the sum of the individual lengths, on average.
            central_node = groups[i0][-1]
            merged_text = "".join([text_chunks[i0], central_node.suffix, text_chunks[i1]])
            merged_text_length = self._count_tokens(merged_text)
            if merged_text_length > self.max_tokens:
                break

            # Update adjacent sum estimates
            if i0 > 0:
                adj_sums[i0 - 1] += merged_text_length
            if i1 < len(adj_sums) - 1:
                adj_sums[i1 + 1] += merged_text_length

            # The potential merge length for this pair is removed
            adj_sums.pop(i0)

            # Merge the pair of node groups
            groups[i0 : i1 + 1] = [groups[i0] + groups[i1]]
            text_chunks[i0 : i1 + 1] = [merged_text]
            lengths[i0 : i1 + 1] = [merged_text_length]

        return groups

    def merge_nodes(self, nodes: List[CodeBlock]) -> CodeBlock:
        if len(nodes) == 0:
            raise ValueError("Cannot merge zero nodes")

        if len(nodes) == 1:
            return nodes[0]

        languages = set(node.language for node in nodes)
        if len(languages) != 1:
            raise ValueError("Nodes have conflicting language")
        (language,) = languages

        prefix = nodes[0].affixes[0]
        suffix = nodes[-1].affixes[-1]
        nodes[0].omit_prefix = True
        nodes[-1].omit_suffix = True
        text = "".join(node.complete_text for node in nodes)
        name = f"{nodes[0].id}:{nodes[-1].id}"
        return CodeBlock(
            text=text,
            name=name,
            id=name,
            start_point=nodes[0].start_point,
            end_point=nodes[-1].end_point,
            start_byte=nodes[0].start_byte,
            end_byte=nodes[-1].end_byte,
            affixes=(prefix, suffix),
            type=NodeType("merge"),
            children=sorted(sum([node.children for node in nodes], [])),
            language=language,
            tokens=self._count_tokens(text),
        )

    def _count_tokens(self, code: str) -> int:
        """Count the number of tokens in the given text.

        Arguments:
            code: The text to count the number of tokens in.

        Returns:
            The number of tokens in the given text.
        """
        return self.model.get_num_tokens(code)

    def _segment_node(self, node: CodeBlock):
        if node.tokens <= self.max_tokens or node.children:
            return

        lines = node.text.split("\n")
        start_byte = node.start_byte
        for i, line in enumerate(lines):
            end_byte = start_byte + len(bytes(line, "utf-8"))

            name = f"{node.name}_line_{i}"
            prefix = "\n" if i > 0 else ""
            suffix = "\n" if i < len(lines) - 1 else ""

            node.children.append(
                CodeBlock(
                    text=line,
                    name=name,
                    id=name,
                    start_point=(node.start_point[0] + i, 0),
                    end_point=(node.start_point[0] + i, len(line)),
                    start_byte=start_byte,
                    end_byte=end_byte,
                    affixes=(prefix, suffix),
                    type=NodeType("segment"),
                    children=[],
                    language=self.language,
                    tokens=self._count_tokens(line),
                )
            )
            start_byte = end_byte + 1

        # Don't forget the newline we split on
        node.children[0].omit_prefix = False
