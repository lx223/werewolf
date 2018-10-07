import { grpc } from 'grpc-web-client';
import { Code } from 'grpc-web-client/dist/Code';
import { Message } from 'google-protobuf';

export interface IGRPCRequestParams {
  rpc: any;
  request: Message;
  onSuccess: (msg: Message) => void;
  onFailure: (code: Code, msg: string | undefined) => void;
}

export function doGRPCRequest(params: IGRPCRequestParams) {
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
        params.onFailure(code, msg);
      }
    }
  });
}
