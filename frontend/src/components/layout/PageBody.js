import Box from "@mui/material/Box";
import './PageBody.scss';

const PageBody = ({children, withPadding = true}) => {

    return <Box
        className="page-body"
        sx={{
            padding: withPadding ? '32px' : '0'
        }}
    >
        {children}
    </Box>
}

export default PageBody;