
% ハミング問題 [1]
% 2^a * 3^b * 5^c という形の数の最初の N 個を求める

% Lists の中を N 倍する
declare
fun lazy {Times Lists N}
   case Lists of (H|T) then
      N * H | {Times T N}
   end
end

% 遅延リストをマージする
declare
fun lazy {Merge Xs Ys}
   case Xs#Ys of (X|Xr) # (Y|Yr) then
      if (X < Y) then X|{Merge Xr Ys}
      elseif (X == Y) then X|{Merge Xr Yr}
      elseif (X > Y) then Y|{Merge Xs Yr}
      end
   end
end

declare
HamList = 1|{Merge
             {Times HamList 2}
             {Merge
              {Times HamList 3}
              {Times HamList 5}}}
{Show {List.take HamList 10}}

declare
fun {Touch N}
   {List.take HamList N}
end

% 一般的なハミング問題
% p[1]^a[1] * p[2]^a[2] * ... * p[k]^a[k] という形の最初の N 個の整数を求めよ
% ここで p[1], p[2], ... p[k] は最初の k 個の整数
% k が与えられた時に任意の N について問題を解くプログラムを作れ
{Show {Sqrt {IntToFloat 5}}}

declare
fun {Iota Min Max}
   if (Min == Max) then [Min]
   else Min|{Iota Min + 1 Max} end
end

% Stream は基本的に List との互換性はない
% Filter の遅延版
declare
fun lazy {StreamFilter Lists Fun}
   case Lists of (H|T) then
      if {Fun H} then H|{StreamFilter T Fun}
      else {StreamFilter T Fun} end
   end
end

declare
fun lazy {StreamMerge H T} H|T end

declare
fun lazy {ListToStream Lists}
   case Lists of (H|T) then
      H|{ListToStream T}
   end
end
A = {ListToStream [2 3 4 5]}

declare
fun lazy {StreamMap Stream Fun}
   case Stream of (H|T) then
      {Fun H} | {StreamMap T Fun}
   end
end

declare
fun lazy {IntStartFrom N}
   N|{IntStartFrom N + 1}
end

declare
fun {StreamTake N List}
   if (N == 0) then nil
   else
      case List of (H|T) then
         H|{StreamTake N - 1 T}
      end
   end
end

% 素数を遅延リストとして計算する
declare
fun {GenPrimes}
   fun lazy {Gen Stream}
      case Stream of (H|T) then
         {StreamMerge H
           {Gen
            {StreamFilter T
             fun {$ X}
                if (X mod H == 0) then false else true end
             end}}}
      end
   end
in {Gen {IntStartFrom 2}} end
PrimesStream = {GenPrimes}

% ハミング問題
declare
fun {GenHamList K}
   fun lazy {Gen Primes}
      case Primes of nil then nil
      [] (H|T) then
         Left = {Times HamList H}
         Right = {Gen T} in
         if (Right == nil) then Left
         else {Merge Left Right} end
      end
   end
   HamList = 1 | {Gen {StreamTake K PrimesStream}}
in
   HamList
end

declare
HamList = {GenHamList 2}
{Browse primes#{StreamTake 10 PrimesStream}}
{Browse generic#{StreamTake 100 HamList}}
{Browse specific#{Touch 100}}


