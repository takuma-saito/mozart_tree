
% 2分木のツリーを表示するプログラム
% TODO:
% テキスト表示用も作成する
% テキスト

declare
[QTk]={Module.link ["x-oz://system/wp/QTk.ozf"]}
proc {QTkShow Object}
   {{QTk.build Object} show}
end

% Window オブジェクト
declare
class Window
   attr
      winHandler
   
   % Window の初期化
   meth init(Width Height)
      Desc = canvas(handle:@winHandler width:Width height:Height)
   in
      {QTkShow td(Desc)}
      {@winHandler create(rect 10 10 (Width - 10) (Height - 10) fill:white outline:blue)}
   end
   
   % 座標 x, y に Box を描く   
   meth drawBox(X Y Width Height Value)
      fun {Multi Value Rate}
         {FloatToInt {IntToFloat Value} * Rate}
      end
      FontPosX = {Multi Width 0.55} + X
      FontPosY =  {Multi Height 0.55} + Y
      Font = {QTk.newFont font(weight:bold size: {Multi Height 0.6})}
   in
      {@winHandler create(rect X Y (X + Width) (Y + Height)
                          fill:green outline:black)}
      {@winHandler create(text FontPosX FontPosY font:Font text:{IntToString Value})}
   end
   
   meth drawLine(X1 Y1 X2 Y2)
      {@winHandler create(line X1 Y1 X2 Y2 fill:black arrow:last)}
   end
end

% declare
% Win = {New Window init(500 300)}
% {Win drawBox(90 90 20 20 11)}

% 順序付き 2分木の構築
declare
fun {Insert X Tree}
   case Tree
   of leaf then tree(value:X left:leaf right:leaf)
   [] tree(value:Value left:LTree right:RTree) andthen X == Value then
      tree(value:X left:LTree right:RTree)
   [] tree(value:Value left:LTree right:RTree) andthen X < Value then
      tree(value:Value left:{Insert X LTree} right:RTree)
   [] tree(value:Value left:LTree right:RTree) andthen X > Value then
      tree(value:Value left:LTree right:{Insert X RTree})
   else
      raise unkownValue(X Value) end
   end
end

% リストから順序木を作る
declare
fun {MakeBinTree List}
   fun {MakeTree InList TreeAccum}
      case InList
      of nil then TreeAccum
      [] (X | Xr) then
         {MakeTree Xr {Insert X TreeAccum}}
      end
   end
   fun {MakeRoot X} tree(value:X left:leaf right:leaf) end
in
   case List
   of nil then raise invalidValue(List) end
   [] (X | Xr) then
      {MakeTree Xr {MakeRoot X}}
   end
end

% 木の描画用に 座標 X, Y を計算する
declare
fun {AddTreeXY Tree Scale ?Width ?Height}
   % Tree の構造体に X, Y レコードを追加する
   fun {AddXY InTree}
      case InTree
      of leaf then leaf
      [] tree(value:Value left:LTree right:RTree) then
         {Adjoin
          tree(x:_ y:_)
          tree(value:Value left:{AddXY LTree} right:{AddXY RTree})}
      end
   end
   % X Y 座標を実際に計算する
   proc {CalcPosXY InTree Level LimLeft ?PosX ?LimRight}
      case InTree
      of tree(x:X y:Y left:leaf right:leaf ...) then
         X = PosX = LimRight = LimLeft
         Y = Level * Scale
      [] tree(x:X y:Y left:LTree right:leaf ...) then
         X = PosX
         Y = Level * Scale
         {CalcPosXY LTree (Level + 1) LimLeft PosX LimRight}
      [] tree(x:X y:Y left:leaf right:RTree ...) then
         X = PosX
         Y = Level * Scale
         {CalcPosXY RTree (Level + 1) LimLeft PosX LimRight}
      [] tree(x:X y:Y left:LTree right:RTree ...) then
         LLimRight RLimRight LPosX RPosX in
         {CalcPosXY LTree (Level + 1) LimLeft LPosX LLimRight}
         {CalcPosXY RTree (Level + 1) (LLimRight + Scale) RPosX RLimRight}
         X = PosX = (LPosX + RPosX) div 2
         Y = Level * Scale
         LimRight = RLimRight
      end
   end
   % 高さの最大値を求める
   fun {MaxHeight InTree}
      MaxHeight = {NewCell 0}
      proc {SearchMaxHeight Tree}
         case Tree of leaf then skip
         [] tree(y:Y right:RTree left:LTree ...) then
            if (Y > @MaxHeight) then
               MaxHeight := Y
            end
            {SearchMaxHeight LTree}
            {SearchMaxHeight RTree}
         end
      end
   in
      {SearchMaxHeight InTree}
      @MaxHeight
   end
   T = {AddXY Tree} PosX W
in
   {CalcPosXY T 1 Scale PosX W}
   Width = W + Scale
   Height = {MaxHeight T} + Scale
   T
end

% 木を描画する
declare
proc {ShowTree BinTree}
   WinHeight WinWidth
   BoxWidth = 14
   BoxHeight = 14
   Scale = 20
   BinTreeXY = {AddTreeXY BinTree (Scale div 5) WinWidth WinHeight}
   Win = {New Window init(WinWidth * Scale WinHeight * Scale)}
   fun {IsNode Tree}
      case Tree of leaf then false else true end
   end
   proc {DrawLine Tree1 Tree2}
      case Tree1 of
         tree(x:X1 y:Y1 ...) then
         case Tree2 of
            tree(x:X2 y:Y2 ...) then
            Padding = {FloatToInt {IntToFloat BoxHeight} * 0.3}
            BHalfWidth = BoxWidth div 2
         in
            {Win drawLine((X1 * Scale + BHalfWidth) (Y1 * Scale + Padding + BoxHeight)
                          (X2 * Scale + BHalfWidth) (Y2 * Scale - Padding))}
         end
      end
   end
   proc {ShowTreeMain Tree}
      case Tree of leaf then skip
      [] tree(x:X y:Y left:LTree right:RTree value:Value) then
         if ({IsNode LTree}) then
            {DrawLine Tree LTree}
         end
         if ({IsNode RTree}) then
            {DrawLine Tree RTree}
         end
         {Win drawBox(X * Scale Y * Scale BoxHeight BoxWidth Value)}
         {ShowTreeMain LTree}
         {ShowTreeMain RTree}
      end
   end
in
   {ShowTreeMain BinTreeXY}
end

declare
BinTree1 = {MakeBinTree [32 38 59 38 27 8 5 103 28 7]}
BinTree2 = {MakeBinTree [33 55 48 27 88 36 59 102 3 8 5 29 7 8 9 10 28]}
BinTree3 = {MakeBinTree [33 55 48 27 88 36 59 102 3 8 5 29 7 8 9 10 28 9 12 385  6 11 12 19 80 27]}
BinTree4 = {MakeBinTree [33 55 48 27 88 36 59 102 3 8 5 29 7 8 9 10 28
                         9 12 385  6 11 12 19 80 27 29 88 99 101 75 77 83]}
{ShowTree BinTree4}
{ShowTree BinTree3}
{ShowTree BinTree2}
{ShowTree BinTree1}

