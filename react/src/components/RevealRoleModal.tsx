import * as React from 'react';
import { Modal, Box, Image } from 'gestalt';
import 'gestalt/dist/gestalt.css';
import { Role } from 'src/generated/werewolf_pb';
import imageForRole from 'src/resources/images/images';

interface IRevealRoleModalProps {
  choseRole: Role;

  onDismiss: () => void;
}

const RevealRoleModal: React.SFC<IRevealRoleModalProps> = (
  props: IRevealRoleModalProps
) => {
  return (
    <Modal
      accessibilityCloseLabel=""
      accessibilityModalLabel=""
      heading="你的身份"
      size="sm"
      onDismiss={() => {
        props.onDismiss();
      }}
    >
      <Box color="darkGray" height={150} width={150}>
        <Image
          alt="square"
          color="transparent"
          fit="cover"
          naturalHeight={150}
          naturalWidth={150}
          src={imageForRole(props.choseRole)}
        />
      </Box>
    </Modal>
  );
};

export default RevealRoleModal;
