
% 平衡 2 分木のハッシュライブラリ
% reference, adam's paper: [Weight balanced binary trees](http://groups.csail.mit.edu/mac/users/adams/BB/)
% reference, Haskell Data.Map code: [Data.Map](http://www.haskell.org/ghc/docs/6.12.2/html/libraries/containers-0.3.0.0/src/Data-Map.html)

% 2 分木の型
% <List K V> = nil | node(size:Int key:<K> value:<V> right:<List K V> left:<List K V>)

% デバック用
declare
proc {S V} {Browse V} {Show V} end
fun {D V} {S V} S end

% 文字列の比較を行う
declare
fun {CompareString Xs Ys}
   case Xs # Ys
   of nil # nil then eq
   [] _ # nil then gt
   [] nil # _ then lt
   [] (X|Xr) # (Y|Yr) then
      if (X > Y) then gt
      elseif (X < Y) then lt
      elseif (X == Y) then {CompareString Xr Yr}
      end
   end
end

declare
fun {CompareInt X Y}
   if (X > Y) then gt
   elseif (X < Y) then lt
   elseif (X == Y) then eq
   end
end

% 2 つの要素が Valid を満たす
declare
fun {Valid2 X Y Fun}
   if {Fun X} andthen {Fun Y} then true
   else false end
end

% 値の比較を行う
declare
fun {Compare X Y}
   if {Valid2 X Y IsString} then
      {CompareString X Y}
   elseif {Valid2 X Y IsInt} then
      {CompareInt X Y}
   else
      raise notComparable(X Y) end
   end
end

% 
% ノードに関する操作
%
declare
Weight = 5

% ノード一つのみ
declare
fun {Leaf Key Value}
   node(size:1 key:Key value:Value right:nil left:nil)
end

declare
fun {Size Node}
   case Node of nil then 0
   else Node.size end
end

declare
fun {Node Key Value Left Right}
   node(size:{Size Right} + {Size Left} + 1 key:Key value:Value left:Left right:Right)
end

declare
fun {SingleL K V L R}
   {Node R.key R.value {Node K V L R.left} R.right}
end

declare
fun {DoubleL K V L R}
   {Node R.left.key R.left.value
    {Node K V L R.left.left}
    {Node R.key R.value R.left.right R.right}}
end

declare
fun {SingleR K V L R}
   {Node L.key L.value L.left {Node K V L.right R}}
end

declare
fun {DoubleR K V L R}
   {Node L.key L.value
    {Node L.right.key L.right.value L.left L.right.left}
    {Node K V L.right.right R}}
end

declare
fun {RotateL Key Value Left Right}
   if ({Size Right.right} > {Size Right.left}) then
      {SingleL Key Value Left Right}
   else
      {DoubleL Key Value Left Right}
   end
end

declare
fun {RotateR Key Value Left Right}
   if ({Size Left.rigth} > {Size Left.left}) then
      {SingleR Key Value Left Right}
   else
      {DoubleR Key Value Left Right}
   end
end

% 木をバランスさせる
declare
fun {Balance Key Value Left Right}
   LS = {Size Left}
   RS = {Size Right}
in
   % 空ノードの場合
   if (LS + RS < 2) then
      {Node Key Value Left Right}
   elseif (RS > Weight * LS) then
      % 右の木の方が大きい場合, 右の要素を左に移す
      {RotateL Key Value Left Right}
   elseif (LS > Weight * RS) then
      % 左の木の方が大きい場合, 左の要素を右に移す
      {RotateR Key Value Left Right}
   % 木がバランスしている場合
   else {Node Key Value Left Right} end
end

% 最小の要素を削除する
declare
fun {DeleteMin Tree}
   case Tree of nil then Tree # nil
   [] node(left:nil right:Right ...) then Tree # nil
   [] node(key:K value:V left:L right:R ...) then
      Min # Remain = {DeleteMin L} in
      Min # {Balance K V Remain R}
   end
end

% 最大の要素を削除する
declare
fun {DeleteMax Tree}
   case Tree of nil then Tree # nil
   [] node(left:Left right:nil ...) then Tree # nil
   [] node(key:K value:V right:R left:L ...) then
      Max # Remain = {DeleteMax R} in
      Max # {Balance K V L Remain}
   end
end

% 既にバランスしている木同士を合わせる
declare
fun {Glue Left Right}
   case Left # Right
   of nil # Right then Right
   [] Left # nil then Left
   else
      if ({Size Left} > {Size Right}) then
         LMaxNode # LRemain = {DeleteMax Left} in
         {Balance LMaxNode.key LMaxNode.value LRemain Right}
      else
         RMinNode # RRemain = {DeleteMin Right} in
         {Balance RMinNode.key RMinNode.value Left RRemain}
      end
   end
end

% 挿入
declare
fun {Insert Tree Key Value}
   case Tree of nil then {Leaf Key Value}
   [] node(key:K value:V right:R left:L ...) then
      case {Compare Key K}
      of gt then
         {Balance K V L {Insert R Key Value}}
         % {Node K V L {Insert R Key Value}}
      [] lt then
         {Balance K V {Insert L Key Value} R}
         % {Node K V {Insert L Key Value} R}
      [] eq then
         {Node Key Value R L}
      end
   end
end

% 検索
declare
fun {Lookup Tree Key}
   case Tree of nil then nil
   [] node(key:K value:V left:L right:R ...) then
      if (Key == K) then V
      elseif (Key > K) then {Lookup R Key}
      elseif (Key < K) then {Lookup L Key}
      end
   end
end

% 全ての要素を出力
declare
fun {Entries Tree}
   fun {DFS Node Accum}
      case Node of nil then Accum
      [] node(right:R left:L key:K value:V ...) then         
         {DFS R {DFS L K#V|Accum}}
      end
   end
in {DFS Tree nil} end

% 削除
declare
fun {Delete Tree Key}
   case Tree of nil then nil
   [] node(right:R left:L key:K value:V ...) then
      if (Key == K) then {Glue R L}
      elseif (Key > K) then {Node K V L {Delete R Key}}
      elseif (Key < K) then {Node K V {Delete L Key} R}
      end
   end
end

%
% テスト用
%

declare
fun {ListToTree Lists}
   {FoldL Lists
    fun {$ Tree Key#Value}
       {Insert Tree Key Value}
    end nil}
end

declare
% Tree = {ListToTree [5#hoge 7#fuga 9#name 18#yes 21#we 28#nano 35#like 41#year]}
Tree = {ListToTree [5#"yes" 7#"fuga" 9#"name" 18#"sorede" 21#"we" 28#"nano" 35#"like" 41#"year"]}
{S Tree}
{S {Entries Tree}}
{S {Entries {Delete Tree 5}}}
{S {Lookup Tree 5}}
% {S {RotateL Tree.key Tree.value Tree.left Tree.right}}
