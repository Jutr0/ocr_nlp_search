import Box from "@mui/material/Box";
import './PageBody.scss';

const PageBody = ({children}) => {


    return <Box className="page-body">
        {children}
    </Box>
}

export default PageBody;