// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.7.6;
// pragma abicoder v2;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721Metadata.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721Holder.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";
import "@openzeppelin/contracts/introspection/ERC165.sol";
import "@openzeppelin/contracts/math/SafeMath.sol";

contract ChainGame is IERC721Receiver, ERC165, ERC721Holder{
    using SafeMath for uint256;
    //userAddr => collateralAddr => balance
    mapping(address => mapping(address => uint256)) public collateralBalance;
    //userAddr => collateralAddr => tokenIds[]
    mapping(address => mapping(address => uint256[])) public equipmentBlanace;
    event DepositCollateral(address from,address[] tokenAddresses,uint256[] amounts);
    event WithdrawCollateral(address from,address[] tokenAddresses,uint256[] amounts);
    event DepositEquipment(address from,address[] tokenAddresses,uint256[] tokenId);
    event WithdrawEquipment(address from,address[] tokenAddresses,uint256[] tokenId);
 

    constructor() {
        _registerInterface(IERC721Receiver.onERC721Received.selector);
    }
    function depositCollateral(address trader,address[] memory tokenAddresses,uint256[] memory amounts) payable external{
        require(tokenAddresses.length == amounts.length,"The length of tokenaddresses and amounts are not equal");
        IERC20 collateral;
        for(uint256 i = 0;i < tokenAddresses.length;i++){
            address tokenAddress = tokenAddresses[i];
            uint256 amount = amounts[i];
            collateral = IERC20(tokenAddress);
            collateral.transferFrom(trader,address(this),amount);
            collateralBalance[trader][tokenAddress] = collateralBalance[trader][tokenAddress].add(amount);
        }
        emit DepositCollateral(trader,tokenAddresses,amounts);
    }

    function withdrawCollateral(address trader,address[] memory tokenAddresses,uint256[] memory amounts)  external{
        require(tokenAddresses.length == amounts.length,"The length of tokenaddresses and amounts are not equal");
        IERC20 collateral;
        address tokenAddress;
        uint256 amount;
        for(uint256 i = 0;i < tokenAddresses.length;i++){
            tokenAddress = tokenAddresses[i];
            amount = amounts[i];
            collateral = IERC20(tokenAddress);
            collateralBalance[trader][tokenAddress] = collateralBalance[trader][tokenAddress].sub(amount);
            require(collateralBalance[trader][tokenAddress] >= 0,"balance must >= 0");
            collateral.transfer(trader,amount);
        }
        emit WithdrawCollateral(trader,tokenAddresses,amounts);
    }

    function depositEquipment(address payable trader,address[] memory tokenAddresses,uint256[] memory tokenIds) payable external{
        require(tokenAddresses.length == tokenIds.length,"The length of tokenaddresses and tokenIds are not equal");
        IERC721Metadata equipment;
        address tokenAddress;
        uint256 tokenId;
        for(uint256 i = 0;i < tokenAddresses.length;i++){
            tokenAddress = tokenAddresses[i];
            tokenId = tokenIds[i];
            equipment = IERC721Metadata(tokenAddress);
            equipment.safeTransferFrom(trader,address(this),tokenId);
            equipmentBlanace[trader][tokenAddress].push(tokenId);
        }
        emit DepositEquipment(trader,tokenAddresses,tokenIds);
    }

    function withdrawEquipment(address payable trader,address[] memory tokenAddresses,uint256[] memory tokenIds)  external{
        require(tokenAddresses.length == tokenIds.length,"The length of tokenaddresses and tokenIds are not equal");
        IERC721Metadata equipment;
        address tokenAddress;
        uint256 tokenId;
        for(uint256 i = 0;i < tokenAddresses.length;i++){
            tokenAddress = tokenAddresses[i];
            tokenId = tokenIds[i];
            equipment = IERC721Metadata(tokenAddress);
            equipment.safeTransferFrom(address(this),trader,tokenId);
            uint256[] memory equipmentIds = equipmentBlanace[trader][tokenAddress];
            for (uint256 index =0 ;index<equipmentIds.length;index++){
                if (equipmentIds[index] == tokenId){
                    for (uint256 j = index;j <equipmentIds.length-1;j ++ ){
                        equipmentIds[j] = equipmentIds[j+1];
                    }
                    equipmentBlanace[trader][tokenAddress].pop();
                }
            }
        }
        emit WithdrawEquipment(trader,tokenAddresses,tokenIds);
    }
}