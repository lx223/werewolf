// package: werewolf
// file: werewolf.proto

var werewolf_pb = require("./werewolf_pb");
var grpc = require("grpc-web-client").grpc;

var GameService = (function () {
  function GameService() {}
  GameService.serviceName = "werewolf.GameService";
  return GameService;
}());

GameService.CreateAndJoinRoom = {
  methodName: "CreateAndJoinRoom",
  service: GameService,
  requestStream: false,
  responseStream: false,
  requestType: werewolf_pb.CreateAndJoinRoomRequest,
  responseType: werewolf_pb.CreateAndJoinRoomResponse
};

GameService.UpdateGameConfig = {
  methodName: "UpdateGameConfig",
  service: GameService,
  requestStream: false,
  responseStream: false,
  requestType: werewolf_pb.UpdateGameConfigRequest,
  responseType: werewolf_pb.UpdateGameConfigResponse
};

GameService.JoinRoom = {
  methodName: "JoinRoom",
  service: GameService,
  requestStream: false,
  responseStream: false,
  requestType: werewolf_pb.JoinRoomRequest,
  responseType: werewolf_pb.JoinRoomResponse
};

GameService.GetRoom = {
  methodName: "GetRoom",
  service: GameService,
  requestStream: false,
  responseStream: false,
  requestType: werewolf_pb.GetRoomRequest,
  responseType: werewolf_pb.GetRoomResponse
};

GameService.TakeSeat = {
  methodName: "TakeSeat",
  service: GameService,
  requestStream: false,
  responseStream: false,
  requestType: werewolf_pb.TakeSeatRequest,
  responseType: werewolf_pb.TakeSeatResponse
};

GameService.CheckRole = {
  methodName: "CheckRole",
  service: GameService,
  requestStream: false,
  responseStream: false,
  requestType: werewolf_pb.CheckRoleRequest,
  responseType: werewolf_pb.CheckRoleResponse
};

GameService.ReassignRoles = {
  methodName: "ReassignRoles",
  service: GameService,
  requestStream: false,
  responseStream: false,
  requestType: werewolf_pb.ReassignRolesRequest,
  responseType: werewolf_pb.ReassignRolesResponse
};

GameService.VacateSeat = {
  methodName: "VacateSeat",
  service: GameService,
  requestStream: false,
  responseStream: false,
  requestType: werewolf_pb.VacateSeatRequest,
  responseType: werewolf_pb.VacateSeatResponse
};

GameService.StartGame = {
  methodName: "StartGame",
  service: GameService,
  requestStream: false,
  responseStream: false,
  requestType: werewolf_pb.StartGameRequest,
  responseType: werewolf_pb.StartGameResponse
};

GameService.TakeAction = {
  methodName: "TakeAction",
  service: GameService,
  requestStream: false,
  responseStream: false,
  requestType: werewolf_pb.TakeActionRequest,
  responseType: werewolf_pb.TakeActionResponse
};

exports.GameService = GameService;

function GameServiceClient(serviceHost, options) {
  this.serviceHost = serviceHost;
  this.options = options || {};
}

GameServiceClient.prototype.createAndJoinRoom = function createAndJoinRoom(requestMessage, metadata, callback) {
  if (arguments.length === 2) {
    callback = arguments[1];
  }
  grpc.unary(GameService.CreateAndJoinRoom, {
    request: requestMessage,
    host: this.serviceHost,
    metadata: metadata,
    transport: this.options.transport,
    debug: this.options.debug,
    onEnd: function (response) {
      if (callback) {
        if (response.status !== grpc.Code.OK) {
          callback(Object.assign(new Error(response.statusMessage), { code: response.status, metadata: response.trailers }), null);
        } else {
          callback(null, response.message);
        }
      }
    }
  });
};

GameServiceClient.prototype.updateGameConfig = function updateGameConfig(requestMessage, metadata, callback) {
  if (arguments.length === 2) {
    callback = arguments[1];
  }
  grpc.unary(GameService.UpdateGameConfig, {
    request: requestMessage,
    host: this.serviceHost,
    metadata: metadata,
    transport: this.options.transport,
    debug: this.options.debug,
    onEnd: function (response) {
      if (callback) {
        if (response.status !== grpc.Code.OK) {
          callback(Object.assign(new Error(response.statusMessage), { code: response.status, metadata: response.trailers }), null);
        } else {
          callback(null, response.message);
        }
      }
    }
  });
};

GameServiceClient.prototype.joinRoom = function joinRoom(requestMessage, metadata, callback) {
  if (arguments.length === 2) {
    callback = arguments[1];
  }
  grpc.unary(GameService.JoinRoom, {
    request: requestMessage,
    host: this.serviceHost,
    metadata: metadata,
    transport: this.options.transport,
    debug: this.options.debug,
    onEnd: function (response) {
      if (callback) {
        if (response.status !== grpc.Code.OK) {
          callback(Object.assign(new Error(response.statusMessage), { code: response.status, metadata: response.trailers }), null);
        } else {
          callback(null, response.message);
        }
      }
    }
  });
};

GameServiceClient.prototype.getRoom = function getRoom(requestMessage, metadata, callback) {
  if (arguments.length === 2) {
    callback = arguments[1];
  }
  grpc.unary(GameService.GetRoom, {
    request: requestMessage,
    host: this.serviceHost,
    metadata: metadata,
    transport: this.options.transport,
    debug: this.options.debug,
    onEnd: function (response) {
      if (callback) {
        if (response.status !== grpc.Code.OK) {
          callback(Object.assign(new Error(response.statusMessage), { code: response.status, metadata: response.trailers }), null);
        } else {
          callback(null, response.message);
        }
      }
    }
  });
};

GameServiceClient.prototype.takeSeat = function takeSeat(requestMessage, metadata, callback) {
  if (arguments.length === 2) {
    callback = arguments[1];
  }
  grpc.unary(GameService.TakeSeat, {
    request: requestMessage,
    host: this.serviceHost,
    metadata: metadata,
    transport: this.options.transport,
    debug: this.options.debug,
    onEnd: function (response) {
      if (callback) {
        if (response.status !== grpc.Code.OK) {
          callback(Object.assign(new Error(response.statusMessage), { code: response.status, metadata: response.trailers }), null);
        } else {
          callback(null, response.message);
        }
      }
    }
  });
};

GameServiceClient.prototype.checkRole = function checkRole(requestMessage, metadata, callback) {
  if (arguments.length === 2) {
    callback = arguments[1];
  }
  grpc.unary(GameService.CheckRole, {
    request: requestMessage,
    host: this.serviceHost,
    metadata: metadata,
    transport: this.options.transport,
    debug: this.options.debug,
    onEnd: function (response) {
      if (callback) {
        if (response.status !== grpc.Code.OK) {
          callback(Object.assign(new Error(response.statusMessage), { code: response.status, metadata: response.trailers }), null);
        } else {
          callback(null, response.message);
        }
      }
    }
  });
};

GameServiceClient.prototype.reassignRoles = function reassignRoles(requestMessage, metadata, callback) {
  if (arguments.length === 2) {
    callback = arguments[1];
  }
  grpc.unary(GameService.ReassignRoles, {
    request: requestMessage,
    host: this.serviceHost,
    metadata: metadata,
    transport: this.options.transport,
    debug: this.options.debug,
    onEnd: function (response) {
      if (callback) {
        if (response.status !== grpc.Code.OK) {
          callback(Object.assign(new Error(response.statusMessage), { code: response.status, metadata: response.trailers }), null);
        } else {
          callback(null, response.message);
        }
      }
    }
  });
};

GameServiceClient.prototype.vacateSeat = function vacateSeat(requestMessage, metadata, callback) {
  if (arguments.length === 2) {
    callback = arguments[1];
  }
  grpc.unary(GameService.VacateSeat, {
    request: requestMessage,
    host: this.serviceHost,
    metadata: metadata,
    transport: this.options.transport,
    debug: this.options.debug,
    onEnd: function (response) {
      if (callback) {
        if (response.status !== grpc.Code.OK) {
          callback(Object.assign(new Error(response.statusMessage), { code: response.status, metadata: response.trailers }), null);
        } else {
          callback(null, response.message);
        }
      }
    }
  });
};

GameServiceClient.prototype.startGame = function startGame(requestMessage, metadata, callback) {
  if (arguments.length === 2) {
    callback = arguments[1];
  }
  grpc.unary(GameService.StartGame, {
    request: requestMessage,
    host: this.serviceHost,
    metadata: metadata,
    transport: this.options.transport,
    debug: this.options.debug,
    onEnd: function (response) {
      if (callback) {
        if (response.status !== grpc.Code.OK) {
          callback(Object.assign(new Error(response.statusMessage), { code: response.status, metadata: response.trailers }), null);
        } else {
          callback(null, response.message);
        }
      }
    }
  });
};

GameServiceClient.prototype.takeAction = function takeAction(requestMessage, metadata, callback) {
  if (arguments.length === 2) {
    callback = arguments[1];
  }
  grpc.unary(GameService.TakeAction, {
    request: requestMessage,
    host: this.serviceHost,
    metadata: metadata,
    transport: this.options.transport,
    debug: this.options.debug,
    onEnd: function (response) {
      if (callback) {
        if (response.status !== grpc.Code.OK) {
          callback(Object.assign(new Error(response.statusMessage), { code: response.status, metadata: response.trailers }), null);
        } else {
          callback(null, response.message);
        }
      }
    }
  });
};

exports.GameServiceClient = GameServiceClient;

