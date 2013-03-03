
% 絶対差三角を求め

 % リストの差分を取る
declare
fun {AbsDiff Lists}
   case Lists
   of [_] then nil
   [] (X|Y|T) then
      {Abs (X - Y)} | {AbsDiff Y|T}
   end
end

{Show {AbsDiff [8 1 12 10]}}

% 集合のマイナス, 対応する要素がない場合は Result が false になる
% A - B のこと
declare
fun {MinusSet A B}
   Set = {Filter A
          fun {$ X}
             if {Member X B} then false else true end
          end}
   Result = {All B
             fun {$ X}
                if {Member X A} then true else false end
             end}
in
   Set # Result
end

{Show {MinusSet [1 2 3 4 5 6 7 8 9 10] [11 5 8]}}

declare
fun {MakeNumbers N}
   {List.number 1 (N * (N + 1) div 2) 1}
end

declare
fun {DiffAbsTriangle N}
   % トライアングルの総ナンバーの配列
   Numbers = {MakeNumbers N}   
   % 各リストに対して N 個選ぶ
   fun {Choice N Lists Fun}
      fun {ChoiceLoop N Lists Accum}
         if (N == 0) then {Fun Accum}
         else
            for continue:Continue return:Return default:failure
               I in Lists do
               Result = {Fun I|Accum} in
               case Result
               of failure then {Continue}
               [] continue then
                  NewResult = {ChoiceLoop N - 1 {List.subtract Lists I} I|Accum} in
                  case NewResult
                  of failure then {Continue}
                  else {Return NewResult} end
               [] Answer then {Return Answer}
               end
            end
         end
      end
   in {ChoiceLoop N Lists nil} end
   % 途中の段を計算する
   % 残りの要素がなくなった時成功
   fun {CalcDownStage UpperStage Remain Accum}
      if ({Length UpperStage} == 1) then continue
      else 
         CurStage = 
         case UpperStage of [H] then H
         else {AbsDiff UpperStage} end
         NewRemain # Result = {MinusSet Remain CurStage} in
         if {Not Result} then failure
         elseif (NewRemain == nil) then CurStage|Accum
         else
            {CalcDownStage CurStage NewRemain CurStage|Accum}
         end
      end
   end
in
   {Choice N Numbers
    fun {$ X}
       Remain # _ = {MinusSet Numbers X} in
       {CalcDownStage X Remain [X]}
    end}
end

declare
fun {Fact N Limit}
   if (Limit == 0) then N
   else N * {Fact N - 1 Limit - 1} end
end

declare
fun {CalcSize N}
   {Fact {Length {MakeNumbers N}} N}
end

{Show {DiffAbsTriangle 7}}

