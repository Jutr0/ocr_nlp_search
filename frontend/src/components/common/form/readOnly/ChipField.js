import {Chip, Stack, Typography} from "@mui/material";

const ChipField = ({label, value, color}) => {

    return <Stack direction="row" alignItems="center">
        <Typography variant="h6" width={100}>{label}</Typography>
        <Chip
            label={value}
            color={color}
            size="small"
            variant="filled"
            clickable={false}
            onClick={() => 0}
        />
    </Stack>
}

export default ChipField;