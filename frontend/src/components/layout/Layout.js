import Navbar from "./Navbar";
import Box from "@mui/material/Box";
import {Container} from "@mui/material";

const Layout = ({children}) => {
    return <Box>
        <Navbar/>
        <Box component="main" sx={{py: 4}}>
            <Container maxWidth="lg">
                {children}
            </Container>
        </Box>
    </Box>
}

export default Layout;