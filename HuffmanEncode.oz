
% デバック用
declare
fun {D X} {Show X} {Browse X} X end
proc {S X} {Show X} {Browse X} end

% ビット演算
% [integer] -> string
declare
fun {BitsToAtom Lists}
   {String.toAtom
    {Map Lists
     fun {$ X} {Int.toString X}.1 end}}
end

declare
fun {AtomToBits Text}
   {Map {AtomToString Text}
    fun {$ X}
       {StringToInt [X]}
    end}
end

% 1 対 1対応のテーブル
declare
class TableClass
   attr
      keyToValue
      valueToKey
   
   meth init(Dict)
      keyToValue := Dict
      valueToKey := {self reverse(Dict $)}
   end
   
   % 逆にする
   meth reverse(Dict $)
      Entries = {Dictionary.entries Dict}
      NewDict = {NewDictionary} in
      for (Key # Value) in Entries do
         {Dictionary.put NewDict Value Key}
      end
      NewDict
   end
   
   % key と value を逆にする
   meth lookup(Key $)
      {self lookupKey(Key $)}
   end
   
   meth lookupKey(Key $)
      {Dictionary.condGet @keyToValue Key nil}
   end
   
   meth lookupValue(Key $)
      {Dictionary.condGet @valueToKey Key nil}
   end
end

% ハフマン木を作る
declare
fun {MakeHTree Text}
   % ソート状態が変わらないようにエントリーを加える
   fun {AddEntry Set Node # Count}
      case Set of nil then [Node # Count]
      [] (X#XCount|Other) then
         if (Count < XCount) then
            Node # Count | Set
         else
            X#XCount | {AddEntry Other Node # Count}
         end
      end
   end
   % ハフマン木をボトムアップで作成する
   fun {GenTree Set}
      case Set
      of [Tree#_] then Tree
      [] (X#XCount|Y#YCount|Other) then
         Count = XCount + YCount in
         {GenTree {AddEntry Other (node(left:X right:Y) # Count)}}
      end
   end
   % ハフマン木生成用の前処理
   % Word 頻度分布 -> 木の集合 へと変換
   fun {MapToTree Words}
      {Map Words
       fun {$ Word#WordCount}
          leaf(word:Word) # WordCount 
       end}
   end
   % 単語頻度で分布を作る
   fun {WordFreq Dict Text}
      case Text of nil then Dict
      [] (H|T) then
         Char = {String.toAtom [H]}
         Result = {Dictionary.condGet Dict Char nil}
      in
         if (Result == nil) then
            {Dictionary.put Dict Char 1}
         else
            {Dictionary.put Dict Char Result + 1}
         end
         {WordFreq Dict T}
      end
   end
   % 文字をソートする
   fun {WordSort Entries}
      {Sort Entries
       fun {$ X Y}
          _ # XCount = X
          _ # YCount = Y in
          if (XCount < YCount) then true else false end
       end}
   end
in
   {GenTree
    {MapToTree
     {WordSort
      {Dictionary.entries
       {WordFreq
        {NewDictionary} Text}}}}}
end

% 木をビット表現のテーブルに変換
declare
fun {HTreeToHTable HTree}
   Dict = {NewDictionary}
   % 深さ優先探索でノードを全て辿る
   proc {DFS HTree Bits}
      case HTree of leaf(word:Word) then
         {Dictionary.put Dict Word {BitsToAtom {Reverse Bits}}}
      [] node(left:Left right:Right) then
         {DFS Left 0|Bits}
         {DFS Right 1|Bits}
      end
   end
in {DFS HTree nil} Dict end

% ハフマン木で符号化
% 左 -> 0, 右 -> 1
declare
fun {Encode Text ?HTree}
   fun {Enc Text HTable Accum}
      case Text of nil then Accum
      [] (Char|Other) then
         Bits = {AtomToBits {HTable lookup({StringToAtom [Char]} $)}} in
         {Enc Other HTable {Append Bits Accum}}
      end
   end X
in
   HTree = {MakeHTree Text}
   {Enc {Reverse Text} {New TableClass init({HTreeToHTable HTree})} nil}
end

% ハフマン木で復号化
% 左 -> 0, 右 -> 1
declare
fun {Decode Stream HTree}
   fun {Dec Stream Tree Words}
      case Stream of nil then Words
      [] (H|T) then
         case Tree
         of leaf(word:Char) then
            {Dec Stream HTree Char|Words}
         [] node(left:Left right:_)
            andthen (H == 0) then {Dec T Left Words}
         [] node(left:_ right:Right)
            andthen (H == 1) then {Dec T Right Words}
         else
            raise unknownValue(H) end
         end
      end
   end
in {Reverse {Dec Stream HTree nil}} end

% 圧縮率
declare
fun {CompressRate Text}
   Stream = {Encode Text _}
   LengthBefore = {IntToFloat {Length Text} * 8}
   LengthAfter = {IntToFloat {Length Stream}} in
   LengthAfter / LengthBefore
end

% メイン処理
declare Stream HTree Text in
Text = "There is no doubt that my lawyer is honest.  For example, when he
          filed his income tax return last year, he declared half of his salary
            as 'unearned income.'"
Stream =  {Encode Text HTree}
{S Stream}
{S {Decode Stream HTree}}
{S {CompressRate Text}}
% {S {Dictionary.entries {HTreeToHTable {MakeHTree Text}}}}


% ハフマン符号化のアルゴリズム
declare
class HuffmanCode
   attr
      code:_
      tree:_
   
   % 初期化
   meth init skip end
      % {self makeHTree(Text $)}
   % end
   
   % ハフマン符号化エンコード
   meth encode(Text $)
      tree := {MakeHTree Text}
      % code := 
   end
   
   % ファイルに出力
   % meth write(File)
   % end
   
   % ファイルから読み取り
   % meth read(File)
   % end
   
   % バイナリ表現で出力する
   % meth show      
   % end
   
   % ハフマン符号化デコード（通常のテキストに戻す）
   % meth decode($)
   % end
end
