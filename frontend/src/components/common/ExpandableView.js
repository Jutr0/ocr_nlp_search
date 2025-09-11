import Box from "@mui/material/Box";
import React, {useState} from "react";
import {Stack, Typography} from "@mui/material";
import Button from "./Button";


const ExpandableView = ({children, title, previewHeight = '13em', expandable = true}) => {

    const [expanded, setExpanded] = useState(false)

    const toggleExpanded = () => setExpanded(prev => !prev)

    return <>
        <Stack direction="row" alignItems='center' spacing={2}>
            <Typography variant="h6" gutterBottom>
                {title}
            </Typography>
            {expandable && <Button onClick={toggleExpanded}>{expanded ? 'Collapse' : 'Expand'}</Button>}
        </Stack>
        <Box
            sx={expandable && {
                maxHeight: expanded ? "none" : previewHeight,
                overflow: expanded ? "visible" : "hidden",
                position: "relative",
            }}
        >
            {children}
            {expandable && !expanded && (
                <Box
                    sx={{
                        position: "absolute",
                        bottom: 0,
                        left: 0,
                        width: "100%",
                        height: "3.2em",
                        background:
                            "linear-gradient(to bottom, rgba(255,255,255,0), rgba(255,255,255,1))",
                    }}
                />
            )}
        </Box>
    </>

}

export default ExpandableView;