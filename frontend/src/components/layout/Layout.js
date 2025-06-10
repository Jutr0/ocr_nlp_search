import Navbar from "./navbar/Navbar";
import Box from "@mui/material/Box";
import {Card} from "@mui/material";
import './Layout.scss';

const Layout = ({children}) => {
    return <Box className="layout">
        <Navbar/>
        <Card className="content" elevation={5}>
            {children}
        </Card>
    </Box>
}

export default Layout;