// package: werewolf
// file: werewolf.proto

import * as jspb from "google-protobuf";

export class VacateSeatRequest extends jspb.Message {
  getSeatId(): string;
  setSeatId(value: string): void;

  serializeBinary(): Uint8Array;
  toObject(includeInstance?: boolean): VacateSeatRequest.AsObject;
  static toObject(includeInstance: boolean, msg: VacateSeatRequest): VacateSeatRequest.AsObject;
  static extensions: {[key: number]: jspb.ExtensionFieldInfo<jspb.Message>};
  static extensionsBinary: {[key: number]: jspb.ExtensionFieldBinaryInfo<jspb.Message>};
  static serializeBinaryToWriter(message: VacateSeatRequest, writer: jspb.BinaryWriter): void;
  static deserializeBinary(bytes: Uint8Array): VacateSeatRequest;
  static deserializeBinaryFromReader(message: VacateSeatRequest, reader: jspb.BinaryReader): VacateSeatRequest;
}

export namespace VacateSeatRequest {
  export type AsObject = {
    seatId: string,
  }
}

export class VacateSeatResponse extends jspb.Message {
  serializeBinary(): Uint8Array;
  toObject(includeInstance?: boolean): VacateSeatResponse.AsObject;
  static toObject(includeInstance: boolean, msg: VacateSeatResponse): VacateSeatResponse.AsObject;
  static extensions: {[key: number]: jspb.ExtensionFieldInfo<jspb.Message>};
  static extensionsBinary: {[key: number]: jspb.ExtensionFieldBinaryInfo<jspb.Message>};
  static serializeBinaryToWriter(message: VacateSeatResponse, writer: jspb.BinaryWriter): void;
  static deserializeBinary(bytes: Uint8Array): VacateSeatResponse;
  static deserializeBinaryFromReader(message: VacateSeatResponse, reader: jspb.BinaryReader): VacateSeatResponse;
}

export namespace VacateSeatResponse {
  export type AsObject = {
  }
}

export class CreateAndJoinRoomRequest extends jspb.Message {
  serializeBinary(): Uint8Array;
  toObject(includeInstance?: boolean): CreateAndJoinRoomRequest.AsObject;
  static toObject(includeInstance: boolean, msg: CreateAndJoinRoomRequest): CreateAndJoinRoomRequest.AsObject;
  static extensions: {[key: number]: jspb.ExtensionFieldInfo<jspb.Message>};
  static extensionsBinary: {[key: number]: jspb.ExtensionFieldBinaryInfo<jspb.Message>};
  static serializeBinaryToWriter(message: CreateAndJoinRoomRequest, writer: jspb.BinaryWriter): void;
  static deserializeBinary(bytes: Uint8Array): CreateAndJoinRoomRequest;
  static deserializeBinaryFromReader(message: CreateAndJoinRoomRequest, reader: jspb.BinaryReader): CreateAndJoinRoomRequest;
}

export namespace CreateAndJoinRoomRequest {
  export type AsObject = {
  }
}

export class CreateAndJoinRoomResponse extends jspb.Message {
  getRoomId(): string;
  setRoomId(value: string): void;

  getUserId(): string;
  setUserId(value: string): void;

  serializeBinary(): Uint8Array;
  toObject(includeInstance?: boolean): CreateAndJoinRoomResponse.AsObject;
  static toObject(includeInstance: boolean, msg: CreateAndJoinRoomResponse): CreateAndJoinRoomResponse.AsObject;
  static extensions: {[key: number]: jspb.ExtensionFieldInfo<jspb.Message>};
  static extensionsBinary: {[key: number]: jspb.ExtensionFieldBinaryInfo<jspb.Message>};
  static serializeBinaryToWriter(message: CreateAndJoinRoomResponse, writer: jspb.BinaryWriter): void;
  static deserializeBinary(bytes: Uint8Array): CreateAndJoinRoomResponse;
  static deserializeBinaryFromReader(message: CreateAndJoinRoomResponse, reader: jspb.BinaryReader): CreateAndJoinRoomResponse;
}

export namespace CreateAndJoinRoomResponse {
  export type AsObject = {
    roomId: string,
    userId: string,
  }
}

export class UpdateGameConfigRequest extends jspb.Message {
  getRoomId(): string;
  setRoomId(value: string): void;

  clearRoleCountsList(): void;
  getRoleCountsList(): Array<UpdateGameConfigRequest.RoleCount>;
  setRoleCountsList(value: Array<UpdateGameConfigRequest.RoleCount>): void;
  addRoleCounts(value?: UpdateGameConfigRequest.RoleCount, index?: number): UpdateGameConfigRequest.RoleCount;

  serializeBinary(): Uint8Array;
  toObject(includeInstance?: boolean): UpdateGameConfigRequest.AsObject;
  static toObject(includeInstance: boolean, msg: UpdateGameConfigRequest): UpdateGameConfigRequest.AsObject;
  static extensions: {[key: number]: jspb.ExtensionFieldInfo<jspb.Message>};
  static extensionsBinary: {[key: number]: jspb.ExtensionFieldBinaryInfo<jspb.Message>};
  static serializeBinaryToWriter(message: UpdateGameConfigRequest, writer: jspb.BinaryWriter): void;
  static deserializeBinary(bytes: Uint8Array): UpdateGameConfigRequest;
  static deserializeBinaryFromReader(message: UpdateGameConfigRequest, reader: jspb.BinaryReader): UpdateGameConfigRequest;
}

export namespace UpdateGameConfigRequest {
  export type AsObject = {
    roomId: string,
    roleCountsList: Array<UpdateGameConfigRequest.RoleCount.AsObject>,
  }

  export class RoleCount extends jspb.Message {
    getRole(): Role;
    setRole(value: Role): void;

    getCount(): number;
    setCount(value: number): void;

    serializeBinary(): Uint8Array;
    toObject(includeInstance?: boolean): RoleCount.AsObject;
    static toObject(includeInstance: boolean, msg: RoleCount): RoleCount.AsObject;
    static extensions: {[key: number]: jspb.ExtensionFieldInfo<jspb.Message>};
    static extensionsBinary: {[key: number]: jspb.ExtensionFieldBinaryInfo<jspb.Message>};
    static serializeBinaryToWriter(message: RoleCount, writer: jspb.BinaryWriter): void;
    static deserializeBinary(bytes: Uint8Array): RoleCount;
    static deserializeBinaryFromReader(message: RoleCount, reader: jspb.BinaryReader): RoleCount;
  }

  export namespace RoleCount {
    export type AsObject = {
      role: Role,
      count: number,
    }
  }
}

export class UpdateGameConfigResponse extends jspb.Message {
  serializeBinary(): Uint8Array;
  toObject(includeInstance?: boolean): UpdateGameConfigResponse.AsObject;
  static toObject(includeInstance: boolean, msg: UpdateGameConfigResponse): UpdateGameConfigResponse.AsObject;
  static extensions: {[key: number]: jspb.ExtensionFieldInfo<jspb.Message>};
  static extensionsBinary: {[key: number]: jspb.ExtensionFieldBinaryInfo<jspb.Message>};
  static serializeBinaryToWriter(message: UpdateGameConfigResponse, writer: jspb.BinaryWriter): void;
  static deserializeBinary(bytes: Uint8Array): UpdateGameConfigResponse;
  static deserializeBinaryFromReader(message: UpdateGameConfigResponse, reader: jspb.BinaryReader): UpdateGameConfigResponse;
}

export namespace UpdateGameConfigResponse {
  export type AsObject = {
  }
}

export class JoinRoomRequest extends jspb.Message {
  getUserId(): string;
  setUserId(value: string): void;

  getRoomId(): string;
  setRoomId(value: string): void;

  serializeBinary(): Uint8Array;
  toObject(includeInstance?: boolean): JoinRoomRequest.AsObject;
  static toObject(includeInstance: boolean, msg: JoinRoomRequest): JoinRoomRequest.AsObject;
  static extensions: {[key: number]: jspb.ExtensionFieldInfo<jspb.Message>};
  static extensionsBinary: {[key: number]: jspb.ExtensionFieldBinaryInfo<jspb.Message>};
  static serializeBinaryToWriter(message: JoinRoomRequest, writer: jspb.BinaryWriter): void;
  static deserializeBinary(bytes: Uint8Array): JoinRoomRequest;
  static deserializeBinaryFromReader(message: JoinRoomRequest, reader: jspb.BinaryReader): JoinRoomRequest;
}

export namespace JoinRoomRequest {
  export type AsObject = {
    userId: string,
    roomId: string,
  }
}

export class JoinRoomResponse extends jspb.Message {
  getUserId(): string;
  setUserId(value: string): void;

  serializeBinary(): Uint8Array;
  toObject(includeInstance?: boolean): JoinRoomResponse.AsObject;
  static toObject(includeInstance: boolean, msg: JoinRoomResponse): JoinRoomResponse.AsObject;
  static extensions: {[key: number]: jspb.ExtensionFieldInfo<jspb.Message>};
  static extensionsBinary: {[key: number]: jspb.ExtensionFieldBinaryInfo<jspb.Message>};
  static serializeBinaryToWriter(message: JoinRoomResponse, writer: jspb.BinaryWriter): void;
  static deserializeBinary(bytes: Uint8Array): JoinRoomResponse;
  static deserializeBinaryFromReader(message: JoinRoomResponse, reader: jspb.BinaryReader): JoinRoomResponse;
}

export namespace JoinRoomResponse {
  export type AsObject = {
    userId: string,
  }
}

export class GetRoomRequest extends jspb.Message {
  getRoomId(): string;
  setRoomId(value: string): void;

  serializeBinary(): Uint8Array;
  toObject(includeInstance?: boolean): GetRoomRequest.AsObject;
  static toObject(includeInstance: boolean, msg: GetRoomRequest): GetRoomRequest.AsObject;
  static extensions: {[key: number]: jspb.ExtensionFieldInfo<jspb.Message>};
  static extensionsBinary: {[key: number]: jspb.ExtensionFieldBinaryInfo<jspb.Message>};
  static serializeBinaryToWriter(message: GetRoomRequest, writer: jspb.BinaryWriter): void;
  static deserializeBinary(bytes: Uint8Array): GetRoomRequest;
  static deserializeBinaryFromReader(message: GetRoomRequest, reader: jspb.BinaryReader): GetRoomRequest;
}

export namespace GetRoomRequest {
  export type AsObject = {
    roomId: string,
  }
}

export class GetRoomResponse extends jspb.Message {
  hasRoom(): boolean;
  clearRoom(): void;
  getRoom(): Room | undefined;
  setRoom(value?: Room): void;

  serializeBinary(): Uint8Array;
  toObject(includeInstance?: boolean): GetRoomResponse.AsObject;
  static toObject(includeInstance: boolean, msg: GetRoomResponse): GetRoomResponse.AsObject;
  static extensions: {[key: number]: jspb.ExtensionFieldInfo<jspb.Message>};
  static extensionsBinary: {[key: number]: jspb.ExtensionFieldBinaryInfo<jspb.Message>};
  static serializeBinaryToWriter(message: GetRoomResponse, writer: jspb.BinaryWriter): void;
  static deserializeBinary(bytes: Uint8Array): GetRoomResponse;
  static deserializeBinaryFromReader(message: GetRoomResponse, reader: jspb.BinaryReader): GetRoomResponse;
}

export namespace GetRoomResponse {
  export type AsObject = {
    room?: Room.AsObject,
  }
}

export class TakeSeatRequest extends jspb.Message {
  getSeatId(): string;
  setSeatId(value: string): void;

  getUserId(): string;
  setUserId(value: string): void;

  serializeBinary(): Uint8Array;
  toObject(includeInstance?: boolean): TakeSeatRequest.AsObject;
  static toObject(includeInstance: boolean, msg: TakeSeatRequest): TakeSeatRequest.AsObject;
  static extensions: {[key: number]: jspb.ExtensionFieldInfo<jspb.Message>};
  static extensionsBinary: {[key: number]: jspb.ExtensionFieldBinaryInfo<jspb.Message>};
  static serializeBinaryToWriter(message: TakeSeatRequest, writer: jspb.BinaryWriter): void;
  static deserializeBinary(bytes: Uint8Array): TakeSeatRequest;
  static deserializeBinaryFromReader(message: TakeSeatRequest, reader: jspb.BinaryReader): TakeSeatRequest;
}

export namespace TakeSeatRequest {
  export type AsObject = {
    seatId: string,
    userId: string,
  }
}

export class TakeSeatResponse extends jspb.Message {
  serializeBinary(): Uint8Array;
  toObject(includeInstance?: boolean): TakeSeatResponse.AsObject;
  static toObject(includeInstance: boolean, msg: TakeSeatResponse): TakeSeatResponse.AsObject;
  static extensions: {[key: number]: jspb.ExtensionFieldInfo<jspb.Message>};
  static extensionsBinary: {[key: number]: jspb.ExtensionFieldBinaryInfo<jspb.Message>};
  static serializeBinaryToWriter(message: TakeSeatResponse, writer: jspb.BinaryWriter): void;
  static deserializeBinary(bytes: Uint8Array): TakeSeatResponse;
  static deserializeBinaryFromReader(message: TakeSeatResponse, reader: jspb.BinaryReader): TakeSeatResponse;
}

export namespace TakeSeatResponse {
  export type AsObject = {
  }
}

export class CheckRoleRequest extends jspb.Message {
  getSeatId(): string;
  setSeatId(value: string): void;

  serializeBinary(): Uint8Array;
  toObject(includeInstance?: boolean): CheckRoleRequest.AsObject;
  static toObject(includeInstance: boolean, msg: CheckRoleRequest): CheckRoleRequest.AsObject;
  static extensions: {[key: number]: jspb.ExtensionFieldInfo<jspb.Message>};
  static extensionsBinary: {[key: number]: jspb.ExtensionFieldBinaryInfo<jspb.Message>};
  static serializeBinaryToWriter(message: CheckRoleRequest, writer: jspb.BinaryWriter): void;
  static deserializeBinary(bytes: Uint8Array): CheckRoleRequest;
  static deserializeBinaryFromReader(message: CheckRoleRequest, reader: jspb.BinaryReader): CheckRoleRequest;
}

export namespace CheckRoleRequest {
  export type AsObject = {
    seatId: string,
  }
}

export class CheckRoleResponse extends jspb.Message {
  getRole(): Role;
  setRole(value: Role): void;

  serializeBinary(): Uint8Array;
  toObject(includeInstance?: boolean): CheckRoleResponse.AsObject;
  static toObject(includeInstance: boolean, msg: CheckRoleResponse): CheckRoleResponse.AsObject;
  static extensions: {[key: number]: jspb.ExtensionFieldInfo<jspb.Message>};
  static extensionsBinary: {[key: number]: jspb.ExtensionFieldBinaryInfo<jspb.Message>};
  static serializeBinaryToWriter(message: CheckRoleResponse, writer: jspb.BinaryWriter): void;
  static deserializeBinary(bytes: Uint8Array): CheckRoleResponse;
  static deserializeBinaryFromReader(message: CheckRoleResponse, reader: jspb.BinaryReader): CheckRoleResponse;
}

export namespace CheckRoleResponse {
  export type AsObject = {
    role: Role,
  }
}

export class ReassignRolesRequest extends jspb.Message {
  getRoomId(): string;
  setRoomId(value: string): void;

  serializeBinary(): Uint8Array;
  toObject(includeInstance?: boolean): ReassignRolesRequest.AsObject;
  static toObject(includeInstance: boolean, msg: ReassignRolesRequest): ReassignRolesRequest.AsObject;
  static extensions: {[key: number]: jspb.ExtensionFieldInfo<jspb.Message>};
  static extensionsBinary: {[key: number]: jspb.ExtensionFieldBinaryInfo<jspb.Message>};
  static serializeBinaryToWriter(message: ReassignRolesRequest, writer: jspb.BinaryWriter): void;
  static deserializeBinary(bytes: Uint8Array): ReassignRolesRequest;
  static deserializeBinaryFromReader(message: ReassignRolesRequest, reader: jspb.BinaryReader): ReassignRolesRequest;
}

export namespace ReassignRolesRequest {
  export type AsObject = {
    roomId: string,
  }
}

export class ReassignRolesResponse extends jspb.Message {
  serializeBinary(): Uint8Array;
  toObject(includeInstance?: boolean): ReassignRolesResponse.AsObject;
  static toObject(includeInstance: boolean, msg: ReassignRolesResponse): ReassignRolesResponse.AsObject;
  static extensions: {[key: number]: jspb.ExtensionFieldInfo<jspb.Message>};
  static extensionsBinary: {[key: number]: jspb.ExtensionFieldBinaryInfo<jspb.Message>};
  static serializeBinaryToWriter(message: ReassignRolesResponse, writer: jspb.BinaryWriter): void;
  static deserializeBinary(bytes: Uint8Array): ReassignRolesResponse;
  static deserializeBinaryFromReader(message: ReassignRolesResponse, reader: jspb.BinaryReader): ReassignRolesResponse;
}

export namespace ReassignRolesResponse {
  export type AsObject = {
  }
}

export class StartGameRequest extends jspb.Message {
  getRoomId(): string;
  setRoomId(value: string): void;

  serializeBinary(): Uint8Array;
  toObject(includeInstance?: boolean): StartGameRequest.AsObject;
  static toObject(includeInstance: boolean, msg: StartGameRequest): StartGameRequest.AsObject;
  static extensions: {[key: number]: jspb.ExtensionFieldInfo<jspb.Message>};
  static extensionsBinary: {[key: number]: jspb.ExtensionFieldBinaryInfo<jspb.Message>};
  static serializeBinaryToWriter(message: StartGameRequest, writer: jspb.BinaryWriter): void;
  static deserializeBinary(bytes: Uint8Array): StartGameRequest;
  static deserializeBinaryFromReader(message: StartGameRequest, reader: jspb.BinaryReader): StartGameRequest;
}

export namespace StartGameRequest {
  export type AsObject = {
    roomId: string,
  }
}

export class StartGameResponse extends jspb.Message {
  serializeBinary(): Uint8Array;
  toObject(includeInstance?: boolean): StartGameResponse.AsObject;
  static toObject(includeInstance: boolean, msg: StartGameResponse): StartGameResponse.AsObject;
  static extensions: {[key: number]: jspb.ExtensionFieldInfo<jspb.Message>};
  static extensionsBinary: {[key: number]: jspb.ExtensionFieldBinaryInfo<jspb.Message>};
  static serializeBinaryToWriter(message: StartGameResponse, writer: jspb.BinaryWriter): void;
  static deserializeBinary(bytes: Uint8Array): StartGameResponse;
  static deserializeBinaryFromReader(message: StartGameResponse, reader: jspb.BinaryReader): StartGameResponse;
}

export namespace StartGameResponse {
  export type AsObject = {
  }
}

export class TakeActionRequest extends jspb.Message {
  getGameId(): string;
  setGameId(value: string): void;

  hasDarkness(): boolean;
  clearDarkness(): void;
  getDarkness(): TakeActionRequest.CompleteDarknessAction | undefined;
  setDarkness(value?: TakeActionRequest.CompleteDarknessAction): void;

  hasSeer(): boolean;
  clearSeer(): void;
  getSeer(): TakeActionRequest.SeerAction | undefined;
  setSeer(value?: TakeActionRequest.SeerAction): void;

  hasWitch(): boolean;
  clearWitch(): void;
  getWitch(): TakeActionRequest.WitchAction | undefined;
  setWitch(value?: TakeActionRequest.WitchAction): void;

  hasHunter(): boolean;
  clearHunter(): void;
  getHunter(): TakeActionRequest.HunterAction | undefined;
  setHunter(value?: TakeActionRequest.HunterAction): void;

  hasGuard(): boolean;
  clearGuard(): void;
  getGuard(): TakeActionRequest.GuardAction | undefined;
  setGuard(value?: TakeActionRequest.GuardAction): void;

  hasWerewolf(): boolean;
  clearWerewolf(): void;
  getWerewolf(): TakeActionRequest.WerewolfAction | undefined;
  setWerewolf(value?: TakeActionRequest.WerewolfAction): void;

  hasHalfBlood(): boolean;
  clearHalfBlood(): void;
  getHalfBlood(): TakeActionRequest.HalfBloodAction | undefined;
  setHalfBlood(value?: TakeActionRequest.HalfBloodAction): void;

  hasSheriff(): boolean;
  clearSheriff(): void;
  getSheriff(): TakeActionRequest.CompleteSheriffAction | undefined;
  setSheriff(value?: TakeActionRequest.CompleteSheriffAction): void;

  hasOrphan(): boolean;
  clearOrphan(): void;
  getOrphan(): TakeActionRequest.OrphanAction | undefined;
  setOrphan(value?: TakeActionRequest.OrphanAction): void;

  getActionCase(): TakeActionRequest.ActionCase;
  serializeBinary(): Uint8Array;
  toObject(includeInstance?: boolean): TakeActionRequest.AsObject;
  static toObject(includeInstance: boolean, msg: TakeActionRequest): TakeActionRequest.AsObject;
  static extensions: {[key: number]: jspb.ExtensionFieldInfo<jspb.Message>};
  static extensionsBinary: {[key: number]: jspb.ExtensionFieldBinaryInfo<jspb.Message>};
  static serializeBinaryToWriter(message: TakeActionRequest, writer: jspb.BinaryWriter): void;
  static deserializeBinary(bytes: Uint8Array): TakeActionRequest;
  static deserializeBinaryFromReader(message: TakeActionRequest, reader: jspb.BinaryReader): TakeActionRequest;
}

export namespace TakeActionRequest {
  export type AsObject = {
    gameId: string,
    darkness?: TakeActionRequest.CompleteDarknessAction.AsObject,
    seer?: TakeActionRequest.SeerAction.AsObject,
    witch?: TakeActionRequest.WitchAction.AsObject,
    hunter?: TakeActionRequest.HunterAction.AsObject,
    guard?: TakeActionRequest.GuardAction.AsObject,
    werewolf?: TakeActionRequest.WerewolfAction.AsObject,
    halfBlood?: TakeActionRequest.HalfBloodAction.AsObject,
    sheriff?: TakeActionRequest.CompleteSheriffAction.AsObject,
    orphan?: TakeActionRequest.OrphanAction.AsObject,
  }

  export class CompleteDarknessAction extends jspb.Message {
    serializeBinary(): Uint8Array;
    toObject(includeInstance?: boolean): CompleteDarknessAction.AsObject;
    static toObject(includeInstance: boolean, msg: CompleteDarknessAction): CompleteDarknessAction.AsObject;
    static extensions: {[key: number]: jspb.ExtensionFieldInfo<jspb.Message>};
    static extensionsBinary: {[key: number]: jspb.ExtensionFieldBinaryInfo<jspb.Message>};
    static serializeBinaryToWriter(message: CompleteDarknessAction, writer: jspb.BinaryWriter): void;
    static deserializeBinary(bytes: Uint8Array): CompleteDarknessAction;
    static deserializeBinaryFromReader(message: CompleteDarknessAction, reader: jspb.BinaryReader): CompleteDarknessAction;
  }

  export namespace CompleteDarknessAction {
    export type AsObject = {
    }
  }

  export class SeerAction extends jspb.Message {
    getSeatId(): string;
    setSeatId(value: string): void;

    serializeBinary(): Uint8Array;
    toObject(includeInstance?: boolean): SeerAction.AsObject;
    static toObject(includeInstance: boolean, msg: SeerAction): SeerAction.AsObject;
    static extensions: {[key: number]: jspb.ExtensionFieldInfo<jspb.Message>};
    static extensionsBinary: {[key: number]: jspb.ExtensionFieldBinaryInfo<jspb.Message>};
    static serializeBinaryToWriter(message: SeerAction, writer: jspb.BinaryWriter): void;
    static deserializeBinary(bytes: Uint8Array): SeerAction;
    static deserializeBinaryFromReader(message: SeerAction, reader: jspb.BinaryReader): SeerAction;
  }

  export namespace SeerAction {
    export type AsObject = {
      seatId: string,
    }
  }

  export class WitchAction extends jspb.Message {
    getPoisonSeatId(): string;
    setPoisonSeatId(value: string): void;

    getCureSeatId(): string;
    setCureSeatId(value: string): void;

    serializeBinary(): Uint8Array;
    toObject(includeInstance?: boolean): WitchAction.AsObject;
    static toObject(includeInstance: boolean, msg: WitchAction): WitchAction.AsObject;
    static extensions: {[key: number]: jspb.ExtensionFieldInfo<jspb.Message>};
    static extensionsBinary: {[key: number]: jspb.ExtensionFieldBinaryInfo<jspb.Message>};
    static serializeBinaryToWriter(message: WitchAction, writer: jspb.BinaryWriter): void;
    static deserializeBinary(bytes: Uint8Array): WitchAction;
    static deserializeBinaryFromReader(message: WitchAction, reader: jspb.BinaryReader): WitchAction;
  }

  export namespace WitchAction {
    export type AsObject = {
      poisonSeatId: string,
      cureSeatId: string,
    }
  }

  export class HunterAction extends jspb.Message {
    serializeBinary(): Uint8Array;
    toObject(includeInstance?: boolean): HunterAction.AsObject;
    static toObject(includeInstance: boolean, msg: HunterAction): HunterAction.AsObject;
    static extensions: {[key: number]: jspb.ExtensionFieldInfo<jspb.Message>};
    static extensionsBinary: {[key: number]: jspb.ExtensionFieldBinaryInfo<jspb.Message>};
    static serializeBinaryToWriter(message: HunterAction, writer: jspb.BinaryWriter): void;
    static deserializeBinary(bytes: Uint8Array): HunterAction;
    static deserializeBinaryFromReader(message: HunterAction, reader: jspb.BinaryReader): HunterAction;
  }

  export namespace HunterAction {
    export type AsObject = {
    }
  }

  export class GuardAction extends jspb.Message {
    getSeatId(): string;
    setSeatId(value: string): void;

    serializeBinary(): Uint8Array;
    toObject(includeInstance?: boolean): GuardAction.AsObject;
    static toObject(includeInstance: boolean, msg: GuardAction): GuardAction.AsObject;
    static extensions: {[key: number]: jspb.ExtensionFieldInfo<jspb.Message>};
    static extensionsBinary: {[key: number]: jspb.ExtensionFieldBinaryInfo<jspb.Message>};
    static serializeBinaryToWriter(message: GuardAction, writer: jspb.BinaryWriter): void;
    static deserializeBinary(bytes: Uint8Array): GuardAction;
    static deserializeBinaryFromReader(message: GuardAction, reader: jspb.BinaryReader): GuardAction;
  }

  export namespace GuardAction {
    export type AsObject = {
      seatId: string,
    }
  }

  export class WerewolfAction extends jspb.Message {
    getSeatId(): string;
    setSeatId(value: string): void;

    serializeBinary(): Uint8Array;
    toObject(includeInstance?: boolean): WerewolfAction.AsObject;
    static toObject(includeInstance: boolean, msg: WerewolfAction): WerewolfAction.AsObject;
    static extensions: {[key: number]: jspb.ExtensionFieldInfo<jspb.Message>};
    static extensionsBinary: {[key: number]: jspb.ExtensionFieldBinaryInfo<jspb.Message>};
    static serializeBinaryToWriter(message: WerewolfAction, writer: jspb.BinaryWriter): void;
    static deserializeBinary(bytes: Uint8Array): WerewolfAction;
    static deserializeBinaryFromReader(message: WerewolfAction, reader: jspb.BinaryReader): WerewolfAction;
  }

  export namespace WerewolfAction {
    export type AsObject = {
      seatId: string,
    }
  }

  export class HalfBloodAction extends jspb.Message {
    getSeatId(): string;
    setSeatId(value: string): void;

    serializeBinary(): Uint8Array;
    toObject(includeInstance?: boolean): HalfBloodAction.AsObject;
    static toObject(includeInstance: boolean, msg: HalfBloodAction): HalfBloodAction.AsObject;
    static extensions: {[key: number]: jspb.ExtensionFieldInfo<jspb.Message>};
    static extensionsBinary: {[key: number]: jspb.ExtensionFieldBinaryInfo<jspb.Message>};
    static serializeBinaryToWriter(message: HalfBloodAction, writer: jspb.BinaryWriter): void;
    static deserializeBinary(bytes: Uint8Array): HalfBloodAction;
    static deserializeBinaryFromReader(message: HalfBloodAction, reader: jspb.BinaryReader): HalfBloodAction;
  }

  export namespace HalfBloodAction {
    export type AsObject = {
      seatId: string,
    }
  }

  export class OrphanAction extends jspb.Message {
    getSeatId(): string;
    setSeatId(value: string): void;

    serializeBinary(): Uint8Array;
    toObject(includeInstance?: boolean): OrphanAction.AsObject;
    static toObject(includeInstance: boolean, msg: OrphanAction): OrphanAction.AsObject;
    static extensions: {[key: number]: jspb.ExtensionFieldInfo<jspb.Message>};
    static extensionsBinary: {[key: number]: jspb.ExtensionFieldBinaryInfo<jspb.Message>};
    static serializeBinaryToWriter(message: OrphanAction, writer: jspb.BinaryWriter): void;
    static deserializeBinary(bytes: Uint8Array): OrphanAction;
    static deserializeBinaryFromReader(message: OrphanAction, reader: jspb.BinaryReader): OrphanAction;
  }

  export namespace OrphanAction {
    export type AsObject = {
      seatId: string,
    }
  }

  export class CompleteSheriffAction extends jspb.Message {
    serializeBinary(): Uint8Array;
    toObject(includeInstance?: boolean): CompleteSheriffAction.AsObject;
    static toObject(includeInstance: boolean, msg: CompleteSheriffAction): CompleteSheriffAction.AsObject;
    static extensions: {[key: number]: jspb.ExtensionFieldInfo<jspb.Message>};
    static extensionsBinary: {[key: number]: jspb.ExtensionFieldBinaryInfo<jspb.Message>};
    static serializeBinaryToWriter(message: CompleteSheriffAction, writer: jspb.BinaryWriter): void;
    static deserializeBinary(bytes: Uint8Array): CompleteSheriffAction;
    static deserializeBinaryFromReader(message: CompleteSheriffAction, reader: jspb.BinaryReader): CompleteSheriffAction;
  }

  export namespace CompleteSheriffAction {
    export type AsObject = {
    }
  }

  export enum ActionCase {
    ACTION_NOT_SET = 0,
    DARKNESS = 2,
    SEER = 3,
    WITCH = 4,
    HUNTER = 5,
    GUARD = 6,
    WEREWOLF = 7,
    HALF_BLOOD = 8,
    SHERIFF = 9,
    ORPHAN = 10,
  }
}

export class TakeActionResponse extends jspb.Message {
  hasSeer(): boolean;
  clearSeer(): void;
  getSeer(): TakeActionResponse.SeerResult | undefined;
  setSeer(value?: TakeActionResponse.SeerResult): void;

  hasHunter(): boolean;
  clearHunter(): void;
  getHunter(): TakeActionResponse.HunterResult | undefined;
  setHunter(value?: TakeActionResponse.HunterResult): void;

  getResultCase(): TakeActionResponse.ResultCase;
  serializeBinary(): Uint8Array;
  toObject(includeInstance?: boolean): TakeActionResponse.AsObject;
  static toObject(includeInstance: boolean, msg: TakeActionResponse): TakeActionResponse.AsObject;
  static extensions: {[key: number]: jspb.ExtensionFieldInfo<jspb.Message>};
  static extensionsBinary: {[key: number]: jspb.ExtensionFieldBinaryInfo<jspb.Message>};
  static serializeBinaryToWriter(message: TakeActionResponse, writer: jspb.BinaryWriter): void;
  static deserializeBinary(bytes: Uint8Array): TakeActionResponse;
  static deserializeBinaryFromReader(message: TakeActionResponse, reader: jspb.BinaryReader): TakeActionResponse;
}

export namespace TakeActionResponse {
  export type AsObject = {
    seer?: TakeActionResponse.SeerResult.AsObject,
    hunter?: TakeActionResponse.HunterResult.AsObject,
  }

  export class SeerResult extends jspb.Message {
    getRuling(): Ruling;
    setRuling(value: Ruling): void;

    serializeBinary(): Uint8Array;
    toObject(includeInstance?: boolean): SeerResult.AsObject;
    static toObject(includeInstance: boolean, msg: SeerResult): SeerResult.AsObject;
    static extensions: {[key: number]: jspb.ExtensionFieldInfo<jspb.Message>};
    static extensionsBinary: {[key: number]: jspb.ExtensionFieldBinaryInfo<jspb.Message>};
    static serializeBinaryToWriter(message: SeerResult, writer: jspb.BinaryWriter): void;
    static deserializeBinary(bytes: Uint8Array): SeerResult;
    static deserializeBinaryFromReader(message: SeerResult, reader: jspb.BinaryReader): SeerResult;
  }

  export namespace SeerResult {
    export type AsObject = {
      ruling: Ruling,
    }
  }

  export class HunterResult extends jspb.Message {
    getRuling(): Ruling;
    setRuling(value: Ruling): void;

    serializeBinary(): Uint8Array;
    toObject(includeInstance?: boolean): HunterResult.AsObject;
    static toObject(includeInstance: boolean, msg: HunterResult): HunterResult.AsObject;
    static extensions: {[key: number]: jspb.ExtensionFieldInfo<jspb.Message>};
    static extensionsBinary: {[key: number]: jspb.ExtensionFieldBinaryInfo<jspb.Message>};
    static serializeBinaryToWriter(message: HunterResult, writer: jspb.BinaryWriter): void;
    static deserializeBinary(bytes: Uint8Array): HunterResult;
    static deserializeBinaryFromReader(message: HunterResult, reader: jspb.BinaryReader): HunterResult;
  }

  export namespace HunterResult {
    export type AsObject = {
      ruling: Ruling,
    }
  }

  export enum ResultCase {
    RESULT_NOT_SET = 0,
    SEER = 1,
    HUNTER = 2,
  }
}

export class Room extends jspb.Message {
  clearSeatsList(): void;
  getSeatsList(): Array<Seat>;
  setSeatsList(value: Array<Seat>): void;
  addSeats(value?: Seat, index?: number): Seat;

  hasGame(): boolean;
  clearGame(): void;
  getGame(): Game | undefined;
  setGame(value?: Game): void;

  getHostId(): string;
  setHostId(value: string): void;

  serializeBinary(): Uint8Array;
  toObject(includeInstance?: boolean): Room.AsObject;
  static toObject(includeInstance: boolean, msg: Room): Room.AsObject;
  static extensions: {[key: number]: jspb.ExtensionFieldInfo<jspb.Message>};
  static extensionsBinary: {[key: number]: jspb.ExtensionFieldBinaryInfo<jspb.Message>};
  static serializeBinaryToWriter(message: Room, writer: jspb.BinaryWriter): void;
  static deserializeBinary(bytes: Uint8Array): Room;
  static deserializeBinaryFromReader(message: Room, reader: jspb.BinaryReader): Room;
}

export namespace Room {
  export type AsObject = {
    seatsList: Array<Seat.AsObject>,
    game?: Game.AsObject,
    hostId: string,
  }
}

export class Seat extends jspb.Message {
  getId(): string;
  setId(value: string): void;

  hasUser(): boolean;
  clearUser(): void;
  getUser(): User | undefined;
  setUser(value?: User): void;

  getRole(): Role;
  setRole(value: Role): void;

  serializeBinary(): Uint8Array;
  toObject(includeInstance?: boolean): Seat.AsObject;
  static toObject(includeInstance: boolean, msg: Seat): Seat.AsObject;
  static extensions: {[key: number]: jspb.ExtensionFieldInfo<jspb.Message>};
  static extensionsBinary: {[key: number]: jspb.ExtensionFieldBinaryInfo<jspb.Message>};
  static serializeBinaryToWriter(message: Seat, writer: jspb.BinaryWriter): void;
  static deserializeBinary(bytes: Uint8Array): Seat;
  static deserializeBinaryFromReader(message: Seat, reader: jspb.BinaryReader): Seat;
}

export namespace Seat {
  export type AsObject = {
    id: string,
    user?: User.AsObject,
    role: Role,
  }
}

export class User extends jspb.Message {
  getId(): string;
  setId(value: string): void;

  getImgUrl(): string;
  setImgUrl(value: string): void;

  serializeBinary(): Uint8Array;
  toObject(includeInstance?: boolean): User.AsObject;
  static toObject(includeInstance: boolean, msg: User): User.AsObject;
  static extensions: {[key: number]: jspb.ExtensionFieldInfo<jspb.Message>};
  static extensionsBinary: {[key: number]: jspb.ExtensionFieldBinaryInfo<jspb.Message>};
  static serializeBinaryToWriter(message: User, writer: jspb.BinaryWriter): void;
  static deserializeBinary(bytes: Uint8Array): User;
  static deserializeBinaryFromReader(message: User, reader: jspb.BinaryReader): User;
}

export namespace User {
  export type AsObject = {
    id: string,
    imgUrl: string,
  }
}

export class Game extends jspb.Message {
  getId(): string;
  setId(value: string): void;

  getState(): Game.State;
  setState(value: Game.State): void;

  clearKilledSeatIdsList(): void;
  getKilledSeatIdsList(): Array<string>;
  setKilledSeatIdsList(value: Array<string>): void;
  addKilledSeatIds(value: string, index?: number): string;

  serializeBinary(): Uint8Array;
  toObject(includeInstance?: boolean): Game.AsObject;
  static toObject(includeInstance: boolean, msg: Game): Game.AsObject;
  static extensions: {[key: number]: jspb.ExtensionFieldInfo<jspb.Message>};
  static extensionsBinary: {[key: number]: jspb.ExtensionFieldBinaryInfo<jspb.Message>};
  static serializeBinaryToWriter(message: Game, writer: jspb.BinaryWriter): void;
  static deserializeBinary(bytes: Uint8Array): Game;
  static deserializeBinaryFromReader(message: Game, reader: jspb.BinaryReader): Game;
}

export namespace Game {
  export type AsObject = {
    id: string,
    state: Game.State,
    killedSeatIdsList: Array<string>,
  }

  export enum State {
    UNKNOWN = 0,
    ORPHAN_AWAKE = 1,
    HALF_BLOOD_AWAKE = 2,
    GUARDIAN_AWAKE = 3,
    WEREWOLF_AWAKE = 4,
    WITCH_AWAKE = 5,
    SEER_AWAKE = 6,
    HUNTER_AWAKE = 7,
    SHERIFF_ELECTION = 8,
  }
}

export enum Role {
  UNKNOWN = 0,
  VILLAGER = 1,
  SEER = 2,
  WITCH = 3,
  HUNTER = 4,
  IDIOT = 5,
  GUARDIAN = 6,
  WEREWOLF = 7,
  WHITE_WEREWOLF = 8,
  ORPHAN = 9,
  HALF_BLOOD = 10,
}

export enum Ruling {
  UNKNOWN_RULING = 0,
  POSITIVE = 1,
  NEGATIVE = 2,
}

