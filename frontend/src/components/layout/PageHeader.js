import {Box, Breadcrumbs, Link, Tab, Tabs, Typography} from '@mui/material';
import './PageHeader.scss';
import {useNavigate} from "react-router-dom";

const PageHeader = ({icon, tabs, onTabChange, activeTab, buttons, breadcrumbs = []}) => {

    const navigate = useNavigate();
    const handleTabChange = (event, newValue) => {
        onTabChange && onTabChange(newValue);
    };

    const handleBreadcrumbClick = (path) => {
        navigate(path);
    };

    return (
        <Box className="page-header">
            <Box className="title">
                {icon}
                <Breadcrumbs separator=">">
                    {breadcrumbs.map((crumb, index) => {
                        const isLast = index === breadcrumbs.length - 1;

                        if (isLast) {
                            return (
                                <Typography
                                    key={index}
                                    variant="h6"
                                    sx={{fontWeight: 'bold'}}
                                >
                                    {crumb.label}
                                </Typography>
                            );
                        } else {
                            return (
                                <Link
                                    key={index}
                                    component="button"
                                    variant="h6"
                                    onClick={() => handleBreadcrumbClick(crumb.path)}
                                    sx={{
                                        textDecoration: 'none',
                                        color: 'inherit',
                                        fontWeight: 'normal',
                                        '&:hover': {
                                            textDecoration: 'underline'
                                        }
                                    }}
                                >
                                    {crumb.label}
                                </Link>
                            );
                        }
                    })}
                </Breadcrumbs>
            </Box>

            {tabs && <Tabs
                value={activeTab}
                onChange={handleTabChange}
                textColor="primary"
                indicatorColor="primary"
            >
                {tabs.map(tab => <Tab key={tab.label} label={tab.label} className="tab" value={tab.value}/>)}
            </Tabs>}
            <Box className='buttons'>
                {buttons && buttons}
            </Box>
        </Box>
    );
};

export default PageHeader;
