import Box from "@mui/material/Box";
import './PageBody.scss';

const PageBody = ({children, withPadding = true, sx}) => {

    return <Box
        className="page-body"
        sx={{
            padding: withPadding ? '32px' : '0',
            ...sx,
        }}
    >
        {children}
    </Box>
}

export default PageBody;