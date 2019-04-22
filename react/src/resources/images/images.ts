import cardBack from './卡背.jpg';
import witch from './女巫.jpg';
import guardian from './守卫.jpg';
import villager from './村民.jpg';
import halfBlood from './混血儿.jpg';
import werewolf from './狼人.jpg';
import hunter from './猎人.jpg';
import whiteWerewolf from './白狼王.jpg';
import confused from './白痴.jpg';
import seer from './预言家.jpg';
import { Role } from '../../generated/werewolf_pb';

const imageForRole = (role: Role): string => {
  switch (role) {
    case Role.UNKNOWN:
      return cardBack;
    case Role.VILLAGER:
      return villager;
    case Role.SEER:
      return seer;
    case Role.WITCH:
      return witch;
    case Role.HUNTER:
      return hunter;
    case Role.IDIOT:
      return confused;
    case Role.GUARDIAN:
      return guardian;
    case Role.WEREWOLF:
      return werewolf;
    case Role.WHITE_WEREWOLF:
      return whiteWerewolf;
    case Role.ORPHAN:
      return '';
    case Role.HALF_BLOOD:
      return halfBlood;
  }
};

export default imageForRole;
