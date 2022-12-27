module ERC721 
  imports DOMAINS

  configuration <ERC721>
                  <caller> 0 </caller>
                  <k> init ~> $PGM:K </k>

                  <accounts>
                    <account color="red" multiplicity="*" type="Map">
                      <operate> .Map </operate>
                      <accountID> 0 </accountID>
                      <balance> 0 </balance>
                    </account>
                  </accounts>

                  <nfts>
                    <nft color="Green" multiplicity="*" type="Map">
                      <nftID> 0 </nftID>
                      <nftOwner> 0 </nftOwner>
                      <nftController> 0 </nftController>
                    </nft>
                  </nfts>

                  <out color="Orchid" stream="stdout"> .List </out>
                </ERC721>

  syntax Value   ::= Int
  syntax Address ::= Int

  syntax AExp    ::= Value | Address
                   | "balanceOf" "(" Address ")"
                   | "ownerOf" "(" Value ")"
                // | "safeTransferFrom" "(" Address "," Address "," Value" "," Data" )"
                   | "safeTransferFrom" "(" Address "," Address "," Value")"
                   | "transferFrom" "(" Address "," Address "," Value")"
                   | "getApproved" "(" Value ")"
                   | "setApprovalForAll" "(" Address "," Bool ")"

  syntax BExp    ::= "throw"
                   | "approve" "(" Address "," Value ")"
                   | "isApprovedForAll" "(" Address "," Address ")"
  


  syntax Event   ::= "Transfer" "(" Address "," Address "," Value ")"
                   | "Approval" "(" Address "," Address "," Value ")"
                   | "ApprovalForAll" "(" Address "," Address "," Bool ")"


  rule <k> S1:Stmt S2:Stmt  =>  S1 ~> S2 ...</k>



  /* balanceOf: IDに対応するアカウントが所有するNFTの個数を返す */
  rule <k> balanceOf(ID)               =>  Balance ...</k>
       <accountID> ID </accountID>
       <balance> Balance </balance>
       requires ID =/=Int 0
  rule <k> balanceOf(0)                =>  throw ...</k>


  /* ownerOf: TokenIDに対応するNFTを所有するアカウントのアドレスを返す */
  rule <k> ownerOf(TokenID)            =>  NFTOwner ...</k>
       <nftID> TokenID </nftID>       
       <nftOwner> NFTOwner </nftOwner>
       requires TokenID =/=Int 0
  rule <k> ownerOf(0)                  =>  throw ...</k>


  /* safeTransferFrom: TokenIDに対応するNFTをFromからToに送信する*/
  rule <k> safeTransferFrom(From, To, TokenID) => . ...</k>
       <nftID> TokenID </nftID> 
       <nftOwner> From                         => To</nftOwner>

  
  /* approve: toに対しtokenIDに対応するNFTの制御権を譲与する */
  rule <k> approve(Approved, TokenID)  => . ...</k>
       <caller> Owner </caller>
       <nftID> TokenID </nftID>
       <nftOwner> Owner </nftOwner>
       <nftController> _               => Approved </nftController>


  /* getApproved: TokenIDに対応するNFTの制御者を返す */
  rule <k> getApproved(TokenID)        => Controller ...</k>
       <nftID> TokenID </nftID>
       <nftController> Controller </nftController> 


  /* setApprovalForAll: この関数を呼び出した人の全NFTの制御権を，Operatorに
   *   譲与するか(isApproved = ture),否か(isApproved = false)を決める */
  rule <k> setApprovalForAll(Operator, Approved) => . ...</k>
       <caller> Caller </caller>
       <accountID> Operator </accountID>
       <operate>... .Map => Caller |-> Approved ...</operate>


  /* Ownerが持つ全てのNFTの制御権がOperatorに譲与されているか */
  rule <k> isApprovedForAll(Owner, Operator)  =>  . ...</k>
       <accountID> Operator </accountID>
       <operate>... Owner |-> true ...</operate>


  /* utilities for erc721-k */
  syntax Stmt    ::= AExp 
                   | BExp
                   | Util
                   | Stmt Stmt [left]
  syntax Util    ::= "makeAccount" "(" Address ")"
                   | "makeNFT" "(" Value "," Address ")"
                   | "makeCaller" "(" Address ")"
                   | "init" [macro]


  rule <k> makeAccount(ID)  =>  . ...</k>
       (.Bag                =>   <account> 
                                   <accountID> ID </accountID> 
                                   <operate> ID |-> true </operate>
                                   <balance> 0 </balance> 
                                 </account>)
       <out>... .List       =>  ListItem(ID) ListItem("\n")</out>

  rule <k> makeNFT(TokenID, Address)  =>  . ...</k>
       (.Bag                          =>  <nft>
                                            <nftID> TokenID </nftID>
                                            <nftOwner> Address </nftOwner>
                                            <nftController> Address </nftController>
                                           </nft>)

  rule <k> makeCaller(Caller)          =>  . ...</k>
       <caller> _                      =>  Caller</caller>

  rule init  => makeAccount(1) makeAccount(2) makeCaller(1) makeNFT(999, 1) 

endmodule