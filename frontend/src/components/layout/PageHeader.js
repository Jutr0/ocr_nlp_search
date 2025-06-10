import {Box, Tab, Tabs, Typography} from '@mui/material';
import './PageHeader.scss';

const PageHeader = ({icon, header, tabs, onTabChange, activeTab}) => {

    const handleTabChange = (event, newValue) => {
        onTabChange && onTabChange(newValue);
    };

    return (
        <Box className="page-header">
            <Box className="title">
                {icon}
                <Typography variant="h6">{header}</Typography>
            </Box>

            {tabs && <Tabs
                value={activeTab}
                onChange={handleTabChange}
                textColor="primary"
                indicatorColor="primary"
            >
                {tabs.map(tab => <Tab label={tab.label} className="tab" value={tab.label}/>)}
            </Tabs>}
        </Box>
    );
};

export default PageHeader;
