module ERC721 
  imports DOMAINS

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
  
  syntax Util    ::= "makeAccount" "(" Address ")"
                   | "makeNFT" "(" Value "," Address ")"

  syntax Stmt    ::= AExp 
                   | BExp
                   | Util
                   | Stmt Stmt [left]

  syntax Event   ::= "Transfer" "(" Address "," Address "," Value ")"
                   | "Approval" "(" Address "," Address "," Value ")"
                   | "ApprovalForAll" "(" Address "," Address "," Bool ")"


  configuration <ERC721>
                  <k> $PGM:K </k>

                  <accounts>
                    <account multiplicity="*" type="Map">
                      <accountID> 0 </accountID>
                      <balance> 0 </balance>
                    </account>
                  </accounts>

                  <nfts>
                    <nft multiplicity="*" type="Map">
                      <nftID> 0 </nftID>
                      <nftOwner> 0 </nftOwner>
                    </nft>
                  </nfts>

                  <out color="Orchid" stream="stdout"> .List </out>
                </ERC721>


  rule <k> S1:Stmt S2:Stmt             => S1 ~> S2 ...</k>

  rule <k> makeAccount(ID)             => . ...</k>
       (.Bag                           =>  <account> 
                                             <accountID> ID </accountID> 
                                             <balance> 0 </balance> 
                                           </account>)
       <out>... .List                  => ListItem(ID) ListItem("\n")</out>

  rule <k> makeNFT(TokenID, Address)   => . ...</k>
       (.Bag                           => <nft>
                                            <nftID> TokenID </nftID>
                                            <nftOwner> Address </nftOwner>
                                           </nft>)


  rule <k> balanceOf(ID)               => Balance ...</k>
       <accountID> ID </accountID>
       <balance> Balance </balance>
       requires ID =/=Int 0
  rule <k> balanceOf(0)                => throw ...</k>


  rule <k> ownerOf(TokenID)            => NFTOwner ...</k>
       <nftID> TokenID </nftID>       
       <nftOwner> NFTOwner </nftOwner>
       requires TokenID =/=Int 0
  rule <k> ownerOf(0)                  => throw ...</k>


  rule <k> safeTransferFrom(From, To, TokenID) => . ...</k>
       <nftID> TokenID </nftID>                   
       <nftOwner> From                         => To</nftOwner>

  // rule <k> isApprovedForAll(Owner, Operator) => true ...</k>
endmodule