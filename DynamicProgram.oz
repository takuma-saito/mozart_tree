
% 最長部分列共通問題
% 2つの文字列の共通文の最大値を出す
% s1 = "abcd" s2 = "bced"
% "bcd"

% 乱数生成器
declare
[Rand] = {Module.link ['Random.ozf']}

declare
proc {S V} {Show V} {Browse V} end
fun {D V} {S V} V end

% 最大値
declare
fun {GenericMax Lists Compare}
   case Lists of nil then nil
   [] (H|T) then
      {FoldL T
       fun {$ Max X} {Compare Max X} end
       H}
   end
end

% 最小値の総称関数
declare
fun {GenericMin Lists Compare}
   case Lists of nil then nil
   [] (H|T) then
      {FoldL T
       fun {$ Min X} {Compare Min X} end
       H}
   end
end

% リストの最小値
declare
fun {MinList Lists}
   {GenericMin Lists
    fun {$ Min X}
       if (Min > X) then X else Min end
    end}
end

% リストの最大
declare
fun {MaxList Lists}
   {GenericMax Lists
    fun {$ Max X}
       if (Max < X) then X else Max end
    end}
end

% リストのリストの長さの最大
declare
fun {MaxList2 Lists}
   {GenericMax Lists
    fun {$ X Y}
       if ({Length X} > {Length Y}) then X else Y end
    end}
end

% List -> Atom
declare
fun {ListToAtom Lists}
    {StringToAtom
     {Flatten
      {Map Lists
       fun {$ X} {Int.toString X} end}}}
end

% Atom -> List
declare
fun {AtomToList Atom}
   {AtomToString Atom}
end

% 2次元配列のラッパー層
declare
class Array2Class
   attr dict
   
   meth init
      dict := {NewDictionary}
   end
   
   meth put(X Y Value)
      {Dictionary.put @dict {VirtualString.toAtom (X#Y)} Value}
   end
   
   meth get(X Y $)
      {Dictionary.condGet @dict {VirtualString.toAtom (X#Y)} nil}
   end
   
   meth entries($)
      {Dictionary.entries @dict}
   end
end

% リストとアトムの変換
declare
fun {ListToAtom Lists}
   fun {ToAtom Lists Accum}
      case Lists of nil then Accum
      [] (H|T) then
         {ToAtom T Accum#H}
      end
   end
in {VirtualString.toAtom {ToAtom Lists nil}} end

% X をキャッシュする
declare Array Cache in
Array = {NewDictionary}
fun {Cache X Fun}
   Value = {Dictionary.condGet Array X nil}
in
   if (Value == nil) then
      NewValue = {Fun X} in
      {Dictionary.put Array X NewValue} NewValue
   else Value end
end

% X Y をキャッシュする
declare Array2 CacheLen2 in
Array2 = {New Array2Class init}
fun {CacheLen2 X Y Fun}
   XLen = {Length X}
   YLen = {Length Y}
   Value = {Array2 get(XLen YLen $)}
in
   if (Value == nil) then
      NewValue = {Fun X Y} in
      {Array2 put(XLen YLen NewValue)} NewValue
   else Value end
end

% T S がマッチする場合
% Xs Ys の最小一致文字列 Ln
declare
fun {Match Xs Ys}
   fun {InMatch Xs Ys}
      {CacheLen2 Xs Ys
       fun {$ Xs Ys}
         case Xs of nil then nil
         [] (X|Xr) then
            case Ys of nil then nil
            [] (Y|Yr) then
               if (X == Y) then
                  {MaxList2 [X|{InMatch Xr Yr} {InMatch Xr Ys} {InMatch Xs Yr}]}
               else
                  {MaxList2 [{InMatch Xr Ys} {InMatch Xs Yr}]}
               end
            end
         end
       end}
   end
in {InMatch Xs Ys} end

{Show {StringToAtom {Match "abcd" "bced"}}}
{Show {StringToAtom {Match "abcdlnmfgdaiudfoadojhofidhaoi" "bcedkbdgdfdoaifudhoihoiaue"}}}

% ナップザック問題
% 重さと価値がそれぞれ wi, vi であるような N 個の品物がある
% これからの品物から重さの総和が W を超えないように選んだ時の価値の総和を求めよ

declare
fun {SoloveNapZac Items WLimit}
   fun {Solove Items WLimit VMax}
      case Items of nil then nil # VMax
      [] (Item | Other) then
         Weight # Value = Item in
         % 重さがリミットを超えた時は入れない
         if (WLimit - Weight < 0) then
            {Solove Other WLimit VMax}
         % 重さがリミット以内の時は, 入れる or 入れる の両方を試みる
         else
            NewItems1 # V1 = {Solove Other WLimit - Weight VMax + Value}
            NewItems2 # V2 = {Solove Other WLimit VMax}
         in
            if (V1 >= V2) then (Item|NewItems1) # V1
            else NewItems2 # V2 end
         end
      end
   end
in {Solove Items WLimit 0} end

% {S {SoloveNapZac [4#5 1#2 7#9 5#7 2#3] 10}}
% -> 14

% {S {SoloveNapZac [2#3 1#2 3#4 2#2] 5}}
% -> 7

% 最長増加部分列問題
% Longest Increasing Sequence
declare
fun {LIS Seq}
   fun {LISMain Seq MaxElem MaxLen}
      % {Cache MaxElem
      %  fun {$ MaxLen}
          case Seq of nil then MaxElem # MaxLen
          [] (SeqH|SeqT) then
             if ({IsFree MaxElem}) orelse (SeqH > MaxElem) then
                NewMaxElem1 # NewMaxLen1 = {LISMain SeqT SeqH MaxLen + 1}
                NewMaxElem2 # NewMaxLen2 = {LISMain SeqT MaxElem MaxLen}
             in
                if (NewMaxLen1 > NewMaxLen2) then
                   NewMaxElem1 # NewMaxLen1
                else
                   NewMaxElem2 # NewMaxLen2
                end
             else
                {LISMain SeqT MaxElem MaxLen}
             end
          end
       % end}
   end
in {LISMain Seq _ 0} end

declare
RandData = {Rand.getRandom 10 1000 50}
{S RandData}
{S {LIS RandData}}
{S {LIS [4 2 3 1 5]}}
% {S {LIS RandData}}
% {S {LIS [4 2 3 1 5]}}

% 分割数
% n 個の区別できない品物を m 個以下に分割する方法の総数を求め M で割る
declare
fun {DivNum N M W}
   fun {Main I J}
      if (I == N) then N
      elseif (J == M) then M
      elseif (I - J >= 0) then
         {Main I + 1 J} + {Main I - J J + 1}
      else
         {Main I + 1 J}
      end
   end
in {Main 1 1} mod W end

{S {DivNum 4 3 10000}}

% 2 - 4 - 1
% プライオリーキューを使う問題

fun {TrackLen Stands Fuel}
   fun {Main Stands CurFuel Q Min}
      if (CurFeul == 0) then
         F = {Pop CurFuel} in
         if F == 0 then failure
         else
            {Main Stands 
         end
      else
      end
      else
         
      end
      if {Pop CFuel} == 0
      case Stands of nil then success # Min
      [] (Distance#NewFuel | T) then
         if ((NewP + P) - Distance) the
            
         else
         end
         {Push PQueue NewFuel}
         {Main T  H|Accum Min + 1}
      end
   end
in {Main Stands P nil 0} end


