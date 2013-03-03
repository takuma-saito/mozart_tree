
% ping pong アプリケーション
% ping : 500 ミリ秒に一回
% pong : 600 ミリ秒に一回
functor
import
   Browser(browse:Browse)
define
   proc {S V} {Browse V} end
   
   proc {DelayShow N Time Msg}
      if (N == 0) then {S Msg#' finished'}
      else
         {Delay Time}
         {S Msg}
         {DelayShow N - 1 Time Msg}
      end
   end
   proc {Ping N} {DelayShow N 500 'ping'} end
   proc {Pong N} {DelayShow N 600 'pong'} end
in
   {S 'Game Start'}
   thread {Ping 50} end
   thread {Pong 50} end
end
