
% リフト制御をエミュレートするスクリプト

% デバック用スクリプト
declare
fun {VtoA V} {VirtualString.toAtom V} end
proc {Print V} {Browse V} {Show V} end
proc {ShowV V} {Print {VtoA V}} end
fun {Debug V} {Print V} V end

% Fun -> State, Handler をそれぞれ引数に取る
% 現在の状態を保存できる
declare
fun {NewPortObject Init Fun}
   Sin in
   thread {FoldL Sin Fun Init _} end
   {NewPort Sin}
end

declare
Port = {NewPortObject
        state(init)
        fun {$ State Handler}
           case Handler
           of yes then
              {Delay 1000}
              {Print yes}
              state(0)
           [] no then
              {Delay 1000}
              {Print no}
              state(1)
           end
        end}

{Print Port

fun {Floor}
end

fun {Floor}
end
