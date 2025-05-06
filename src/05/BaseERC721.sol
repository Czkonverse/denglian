// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/Address.sol";
import "@openzeppelin/contracts/utils/Context.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";

contract BaseERC721 {
    using Strings for uint256;
    using Address for address;

    // Token name
    string private _name;

    // Token symbol
    string private _symbol;

    // Token baseURI
    string private _baseURI;

    // Mapping from token ID to owner address
    mapping(uint256 => address) private _owners;

    // Mapping owner address to token count
    mapping(address => uint256) private _balances;

    // Mapping from token ID to approved address
    mapping(uint256 => address) private _tokenApprovals;

    // Mapping from owner to operator approvals
    mapping(address => mapping(address => bool)) private _operatorApprovals;

    /**
     * @dev Emitted when `tokenId` token is transferred from `from` to `to`.
     */
    event Transfer(
        address indexed from,
        address indexed to,
        uint256 indexed tokenId
    );

    /**
     * @dev Emitted when `owner` enables `approved` to manage the `tokenId` token.
     */
    event Approval(
        address indexed owner,
        address indexed approved,
        uint256 indexed tokenId
    );

    /**
     * @dev Emitted when `owner` enables or disables (`approved`) `operator` to manage all of its assets.
     */
    event ApprovalForAll(
        address indexed owner,
        address indexed operator,
        bool approved
    );

    /**
     * @dev Initializes the contract by setting a `name`, a `symbol` and a `baseURI` to thcodee token collection.
     */
    constructor(
        string memory name_,
        string memory symbol_,
        string memory baseURI_
    ) {
        /**code*/
        _name = name_;
        _symbol = symbol_;
        _baseURI = baseURI_;
    }

    // Check
    // /**
    //  * @dev See {IERC165-supportsInterface}.
    //  */
    // function supportsInterface(bytes4 interfaceId) public pure returns (bool) {
    //     return
    //         interfaceId == 0x01ffc9a7 || // ERC165 Interface ID for ERC165
    //         interfaceId == 0x80ac58cd || // ERC165 Interface ID for ERC721
    //         interfaceId == 0x5b5e139f; // ERC165 Interface ID for ERC721Metadata
    // }

    /**
     * @dev See {IERC721Metadata-name}.
     */
    function name() public view returns (string memory) {
        /**code*/
        return _name;
    }

    /**
     * @dev See {IERC721Metadata-symbol}.
     */
    function symbol() public view returns (string memory) {
        /**code*/
        return _symbol;
    }

    /**
     * @dev See {IERC721Metadata-tokenURI}.
     */
    function tokenURI(uint256 tokenId) public view returns (string memory) {
        require(
            /**code*/
            _exists(tokenId),
            "ERC721Metadata: URI query for nonexistent token"
        );

        // should return baseURI
        /**code*/
        return string(abi.encodePacked(_baseURI, tokenId.toString()));

        // return _baseURI;
    }

    /**
     * @dev Mints `tokenId` and transfers it to `to`.
     *
     *
     * Requirements:
     *
     * - `to` cannot be the zero address.
     * - `tokenId` must not exist.
     *
     * Emits a {Transfer} event.
     */
    function mint(address to, uint256 tokenId) public {
        require(/**code*/ to != address(0), "ERC721: mint to the zero address");
        require(/**code*/ !_exists(tokenId), "ERC721: token already minted");

        /**code*/
        _balances[to] += 1;
        _owners[tokenId] = to;

        emit Transfer(address(0), to, tokenId);
    }

    /**
     * @dev See {IERC721-balanceOf}.
     *  授权某个地址 to，可以操作当前发起合约的用户（msg.sender）拥有的某个特定 NFT（tokenId）。
     * balanceOf 的语义是“查询某个地址拥有多少个 token”，只要地址合法（不是 0x0），就应该可以查询。就像你可以查一个地址有没有钱，不管这个地址有没有交易记录，余额就是 0 而已。
     */
    function balanceOf(address owner) public view returns (uint256) {
        return _balances[owner];
    }

    /**
     * @dev See {IERC721-ownerOf}.
     */
    function ownerOf(uint256 tokenId) public view returns (address) {
        address owner = _owners[tokenId];

        return owner;
    }

    /**
     * @dev See {IERC721-approve}.
     * 授权某个地址 to，可以操作当前发起合约的用户（msg.sender）拥有的某个特定 NFT（tokenId）。
     */
    function approve(address to, uint256 tokenId) public {
        address owner = ownerOf(tokenId);
        require(
            /**code*/
            to != owner,
            "ERC721: approval to current owner"
        );

        address sender = msg.sender;
        require(
            /**code*/
            sender == owner || isApprovedForAll(owner, sender),
            "ERC721: approve caller is not owner nor approved for all"
        );

        _approve(to, tokenId);
    }

    /**
     * @dev See {IERC721-getApproved}.
     * 查看某个 token 当前“单次授权”的接收者是谁（如果有），返回的是可以调用 transferFrom 的地址。没有授权就返回 address(0)。
     */
    function getApproved(uint256 tokenId) public view returns (address) {
        require(
            /**code*/
            _exists(tokenId),
            "ERC721: approved query for nonexistent token"
        );

        /**code*/
        return _tokenApprovals[tokenId];
    }

    /**
     * @dev See {IERC721-setApprovalForAll}.
     * 设置某个地址 operator 为 msg.sender 的“全局授权”，也就是 msg.sender 允许这个地址操作自己所有的 token。
     * operator: 被授权操作你所有 NFT 的地址（如交易市场或代理合约）
     * approved: 是否授权 true（授权）或 false（取消授权）
     * 功能说明：
     * 这个函数是批量授权的核心，允许用户把自己“所有的 NFT”交由一个地址代为管理。
     * 如果你想让 OpenSea 或某个 staking 合约帮你操作你的 NFT，通常需要调用这个函数。
     */

    function setApprovalForAll(address operator, bool approved) public {
        address sender = msg.sender;
        require(
            /**code*/
            operator != sender,
            "ERC721: approve to caller"
        );

        /**code*/
        _operatorApprovals[sender][operator] = approved;
        emit ApprovalForAll(sender, operator, approved);
    }

    /**
     * @dev See {IERC721-isApprovedForAll}.
     */
    function isApprovedForAll(
        address owner,
        address operator
    ) public view returns (bool) {
        /**code*/
        return _operatorApprovals[owner][operator];
    }

    /**
     * @dev See {IERC721-transferFrom}.
     * 实现 NFT 所有权变更的基础方法，要求调用者是 NFT 的拥有者或授权地址。
     */
    function transferFrom(address from, address to, uint256 tokenId) public {
        require(
            _isApprovedOrOwner(msg.sender, tokenId),
            "ERC721: transfer caller is not owner nor approved"
        );

        _transfer(from, to, tokenId);
    }

    /**
     * @dev See {IERC721-safeTransferFrom}.
     * 函数重载（Function Overloading） 是指在同一个合约中，可以定义多个函数名相同但参数不同的函数。
     */
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId
    ) public {
        safeTransferFrom(from, to, tokenId, "");
    }

    /**
     * @dev See {IERC721-safeTransferFrom}.
     * 函数重载（Function Overloading） 是指在同一个合约中，可以定义多个函数名相同但参数不同的函数。
     */
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId,
        bytes memory _data
    ) public {
        require(
            _isApprovedOrOwner(msg.sender, tokenId),
            "ERC721: transfer caller is not owner nor approved"
        );
        _safeTransfer(from, to, tokenId, _data);
    }

    /**
     * @dev Safely transfers `tokenId` token from `from` to `to`, checking first that contract recipients
     * are aware of the ERC721 protocol to prevent tokens from being forever locked.
     *
     * `_data` is additional data, it has no specified format and it is sent in call to `to`.
     *
     * This internal function is equivalent to {safeTransferFrom}, and can be used to e.g.
     * implement alternative mechanisms to perform token transfer, such as signature-based.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must exist and be owned by `from`.
     * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon a safe transfer.
     *
     * Emits a {Transfer} event.
     * 在完成普通转账的基础上，检查接收方是否是一个能接收 NFT 的智能合约地址。
     */
    function _safeTransfer(
        address from,
        address to,
        uint256 tokenId,
        bytes memory _data
    ) internal {
        _transfer(from, to, tokenId);
        require(
            _checkOnERC721Received(from, to, tokenId, _data),
            "ERC721: transfer to non ERC721Receiver implementer"
        );
    }

    /**
     * @dev Returns whether `tokenId` exists.
     *
     * Tokens can be managed by their owner or approved accounts via {approve} or {setApprovalForAll}.
     *
     * Tokens start existing when they are minted (`_mint`),
     * and stop existing when they are burned (`_burn`).
     */
    function _exists(uint256 tokenId) internal view returns (bool) {
        /**code*/
        return _owners[tokenId] != address(0);
    }

    /**
     * @dev Returns whether `spender` is allowed to manage `tokenId`.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     */
    function _isApprovedOrOwner(
        address spender,
        uint256 tokenId
    ) internal view returns (bool) {
        require(
            /**code*/
            _exists(tokenId),
            "ERC721: operator query for nonexistent token"
        );

        /**code*/
        address owner = ownerOf(tokenId);
        return (spender == owner || // 是本人
            getApproved(tokenId) == spender || // 是被单次授权的地址
            isApprovedForAll(owner, spender)); // 是被 owner 批量授权的地址（全局授权）
    }

    /**
     * @dev Transfers `tokenId` from `from` to `to`.
     *  As opposed to {transferFrom}, this imposes no restrictions on msg.sender.
     *
     * Requirements:
     *
     * - `to` cannot be the zero address.
     * - `tokenId` token must be owned by `from`.
     *
     * Emits a {Transfer} event.
     */
    function _transfer(address from, address to, uint256 tokenId) internal {
        // 确保你传入的 from 参数，确实是该 tokenId 当前的拥有者。
        require(
            /**code*/
            ownerOf(tokenId) == from,
            "ERC721: transfer from incorrect owner"
        );

        require(
            /**code*/
            to != address(0),
            "ERC721: transfer to the zero address"
        );

        /**code*/
        _approve(address(0), tokenId); // 每次转移 NFT 成功后，之前对该 NFT 的单次授权（approve）将被清除。
        _balances[from] -= 1; // from 的 NFT 数量 -1
        _balances[to] += 1; // to 的 NFT 数量 +1
        _owners[tokenId] = to; // tokenId 的拥有者变更为 to

        emit Transfer(from, to, tokenId);
    }

    /**
     * @dev Approve `to` to operate on `tokenId`
     *
     * Emits a {Approval} event.
     */
    function _approve(address to, uint256 tokenId) internal virtual {
        /**code*/
        _tokenApprovals[tokenId] = to;

        emit Approval(ownerOf(tokenId), to, tokenId);
    }

    /**
     * @dev Internal function to invoke {IERC721Receiver-onERC721Received} on a target address.
     * The call is not executed if the target address is not a contract.
     *
     * @param from address representing the previous owner of the given token ID
     * @param to target address that will receive the tokens
     * @param tokenId uint256 ID of the token to be transferred
     * @param _data bytes optional data to send along with the call
     * @return bool whether the call correctly returned the expected magic value
     */
    function _checkOnERC721Received(
        address from,
        address to,
        uint256 tokenId,
        bytes memory _data
    ) private returns (bool) {
        if (to.isContract()) {
            try
                IERC721Receiver(to).onERC721Received(
                    msg.sender,
                    from,
                    tokenId,
                    _data
                )
            returns (bytes4 retval) {
                return retval == IERC721Receiver.onERC721Received.selector;
            } catch (bytes memory reason) {
                if (reason.length == 0) {
                    revert(
                        "ERC721: transfer to non ERC721Receiver implementer"
                    );
                } else {
                    assembly {
                        revert(add(32, reason), mload(reason))
                    }
                }
            }
        } else {
            return true;
        }
    }
}

contract BaseERC721Receiver is IERC721Receiver {
    constructor() {}

    function onERC721Received(
        address,
        address,
        uint256,
        bytes calldata
    ) external pure returns (bytes4) {
        return this.onERC721Received.selector;
    }
}
