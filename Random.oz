
% 乱数を生成させる
functor
export
   getRandom: GetRandom
   randList: RandList
define   
   % 遅延評価版
   local A = 58382 B = 29834792 M = 100000000 in
      fun lazy {RandList Seed}
         NewSeed = (A * Seed + B) mod M in NewSeed|{RandList NewSeed}
      end
      
      fun {GetRandom Seed Max Count}
         {Map {List.take {RandList Seed} Count}
          fun {$ X}
             (X mod Max) + 1
          end}
      end
   end
end
