import * as React from 'react';
import { Box, Button } from 'gestalt';
import 'gestalt/dist/gestalt.css';

enum SeatColour {
  vacant = 'gray',
  taken = 'red',
  takenByMe = 'blue'
}

interface ISeatProps {
  no: number;
  occupierId?: string;
  myUserId: string;

  onClick: (seatNo: number) => void;
}

const Seat: React.SFC<ISeatProps> = (props: ISeatProps) => {
  return (
    <Box color="white" padding={1}>
      <Button
        text={props.no.toString()}
        color={!!props.occupierId ? 
                  props.occupierId === props.myUserId ? SeatColour.takenByMe : SeatColour.taken 
                    : SeatColour.vacant}
        onClick={() => {
          props.onClick(props.no);
        }}
      />
    </Box>
  );
};

export default Seat;
