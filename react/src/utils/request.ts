import { grpc } from 'grpc-web-client';
import { Code } from 'grpc-web-client/dist/Code';
import { Message } from 'google-protobuf';
import { GameService } from '../generated/werewolf_pb_service';
import { TakeSeatRequest } from '../generated/werewolf_pb';

interface IGRPCRequestCallbackParams {
  onSuccess?: (msg: Message) => void;
  onFailure?: (code: Code, msg: string | undefined) => void;
}

export interface IGRPCRequestParams {
  rpc: any;
  request: Message;
}

export function doGRPCRequest(
  params: IGRPCRequestParams & IGRPCRequestCallbackParams
) {
  grpc.invoke(params.rpc, {
    request: params.request,
    host: 'http://localhost:21807',
    onMessage: params.onSuccess,
    onEnd: (
      code: grpc.Code,
      msg: string | undefined,
      trailers: grpc.Metadata
    ) => {
      if (code !== grpc.Code.OK) {
        params.onFailure!(code, msg);
      }
    }
  });
}

export interface ITakeSeatParams {
  seatId: string;
  userId: string;
}

export function takeSeat(params: ITakeSeatParams & IGRPCRequestCallbackParams) {
  const req = new TakeSeatRequest();
  req.setSeatId(params.seatId);
  req.setUserId(params.userId);
  doGRPCRequest({
    rpc: GameService.TakeSeat,
    request: req,
    onSuccess: params.onSuccess,
    onFailure: params.onFailure
  });
}
