import { Role, Seat as PbSeat } from 'src/generated/werewolf_pb';

export class Seat {
  public id: string;
  public assignedRole: Role;
  public occupierUserId?: string;

  constructor(pbSeat: PbSeat) {
    this.id = pbSeat.getId();
    this.assignedRole = pbSeat.getRole();
    this.occupierUserId = pbSeat.hasUser()
      ? pbSeat.getUser()!.getId()
      : undefined;
  }
}
