module ERC721 
  imports DOMAINS

  configuration <ERC721>
                  <k> $PGM:K </k>
                  <caller> 0 </caller>

                  <accounts>
                    <account color="red" multiplicity="*" type="Map">
                      <accountID> 0 </accountID>
                      <balance> 0 </balance>
                      <operate> .Map </operate>
                    </account>
                  </accounts>

                  <nfts>
                    <nft color="Green" multiplicity="*" type="Map">
                      <nftID> 0 </nftID>
                      <nftOwner> 0 </nftOwner>
                      <nftController> 0 </nftController>
                    </nft>
                  </nfts>

				  <log> Event: </log>
                </ERC721>

  /* ERC-721の関数の引数に使われる型のシノニム */
  syntax Value   ::= Int
  syntax Address ::= Int

  /* AExp: Boolでない返り値を持つ関数 */
  syntax AExp    ::= Value | Address
                   | "balanceOf" "(" Address ")"
                   | "ownerOf" "(" Value ")"
                // | "safeTransferFrom" "(" Address "," Address "," Value" "," Data" )"
                   | "safeTransferFrom" "(" Address "," Address "," Value")"
                   | "transferFrom" "(" Address "," Address "," Value")"
                   | "getApproved" "(" Value ")"
                   | "setApprovalForAll" "(" Address "," Bool ")"

  /* BExp: 返り値がBoolであるような関数 */
  syntax BExp    ::= "throw"
                   | "approve" "(" Address "," Value ")"
                   | "isApprovedForAll" "(" Address "," Address ")"
  
  syntax Event   ::= "Transfer" "(" Address "," Address "," Value ")"
                   | "Approval" "(" Address "," Address "," Value ")"
                   | "ApprovalForAll" "(" Address "," Address "," Bool ")"

  syntax EvtLog  ::= "Event: "
			       | EvtLog Event


  /* 関数を続けて書くための規則．一般的なプログラミング言語であれば自明に以下のような
     コードは上から下へ実行されるが，Kの出力した処理系ではそこも実装を行わなければな
     らない．
     e.g.) transferFrom(from, to, NFT)
           ownerOf(NFT)
           ...                                */
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
	   <log> Log                               => Log Transfer(From, To, TokenID)</log>
	   <balance> Balance                       => Balance -Int 1</balance>

  
  /* approve: Approvedに対しtokenIDに対応するNFTの制御権を譲与する */
  rule <k> approve(Approved, TokenID)  => . ...</k>
	   <accountID> Approved </accountID>
       <caller> Owner </caller>
       <nftID> TokenID </nftID>
       <nftOwner> Owner </nftOwner>
       <nftController> _               => Approved </nftController>
	   <log> Log                       => Log Approval(Owner, Approved, TokenID)</log>


  /* getApproved: TokenIDに対応するNFTの制御者を返す */
  rule <k> getApproved(TokenID)        => Controller ...</k>
       <nftID> TokenID </nftID>
       <nftController> Controller </nftController> 


  /* setApprovalForAll: この関数を呼び出した人の全NFTの制御権を，Operatorに
   *   譲与するか(isApproved = ture),否か(isApproved = false)を決める */
  rule <k> setApprovalForAll(Operator, Approved) => . ...</k>
       <caller> Caller </caller>
       <accountID> Operator </accountID>
       <operate>... .Map                         => Caller |-> Approved ...</operate>
	   <log> Log                                 => Log ApprovalForAll(Caller, Operator, Approved)</log>   


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
                   | "setCaller" "(" Address ")"


  rule <k> makeAccount(ID)  =>  . ...</k>
       (.Bag                =>   <account> 
                                   <accountID> ID </accountID> 
                                   <operate> ID |-> true </operate>
                                   <balance> 0 </balance> 
                                 </account>)

  rule <k> makeNFT(TokenID, Address)  =>  . ...</k>
       (.Bag                          =>  <nft>
                                            <nftID> TokenID </nftID>
                                            <nftOwner> Address </nftOwner>
                                            <nftController> Address </nftController>
                                          </nft>)

  rule <k> setCaller(Caller)          =>  . ...</k>
       <caller> _                     =>  Caller</caller>

endmodule
