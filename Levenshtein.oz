
% レーベシュタイン距離, ハミング距離を計算するアルゴリズム
% 文字の挿入や削除、置換によって、一つの文字列を別の文字列に変形するのに必要な手順の最小回数
% kitten sitting の場合 3
% abd abc の場合 1
% 動的計画法で解ける

declare
fun {Max Lists}
   {FoldL Lists.2
    fun {$ X Accum}
       if (X > Accum) then X else Accum end
    end Lists.1}
end

declare
fun {Min Lists}
   {FoldL Lists.2
    fun {$ X Accum}
       if (X < Accum) then X else Accum end
    end Lists.1}
end

declare
NDict = NewDictionary

% キャッシュ
declare
fun {Get Dict Word1 Word2}
   case {Dictionary.condGet Dict {Length Word1} nil}
   of nil then nil
   [] Dict2 andthen {IsDictionary Dict2} then
      {Dictionary.condGet Dict2 {Length Word2} nil}
   [] Value then Value
   end
end

declare
proc {Put Dict Word1 Word2 Value}
   Dict2 =
   case {Dictionary.condGet Dict {Length Word1} nil}
   of nil then {NewDictionary}
   [] Dict2 then Dict2 end
in
   {Dictionary.put Dict2 {Length Word2} Value}
   {Dictionary.put Dict {Length Word1} Dict2}
end

declare
fun {Distance Word1 Word2 Dict}
   % キャッシュを入れる
   case {Get Dict Word1 Word2} of nil then
      Value =
      case Word1 # Word2
      of nil # nil then 0
      [] Word1 # nil then {Length Word1}
      [] nil # Word2 then {Length Word2}
      [] (H1|T1) # (H2|T2) then
         if (H1 == H2) then
            {Distance T1 T2 Dict}
         else
            1 + {Min [{Distance T1 T2 Dict} {Distance T1 Word2 Dict} {Distance Word1 T2 Dict}]}
         end
      end in
      {Put Dict Word1 Word2 Value}
      Value
   [] Value then Value end
end

{Show {Distance "owaritohazimari" "hazimaritoowari" {NDict}}}
{Show {Distance "takuma" "saito" {NDict}}}
{Show {Distance "erik" "veenstra" {NDict}}}
{Show {Distance "kitten" "sitting" {NDict}}}


