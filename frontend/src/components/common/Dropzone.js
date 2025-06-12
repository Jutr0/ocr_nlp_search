import { Paper, Box, Typography } from '@mui/material';
import { useDropzone } from 'react-dropzone';

const Dropzone = ({ onDrop, value, multiple = false }) => {

    const { getRootProps, getInputProps, isDragActive } = useDropzone({
        onDrop,
        accept: {
            'application/pdf': ['.pdf'],
            'image/*': ['.jpg', '.jpeg', '.png'],
        },
        multiple,
    });

    return (
        <Paper
            {...getRootProps()}
            elevation={3}
            sx={{
                p: 4,
                textAlign: 'center',
                border: '2px dashed',
                borderColor: isDragActive ? 'primary.main' : 'grey.400',
                bgcolor: isDragActive ? 'grey.100' : 'background.paper',
                cursor: 'pointer',
                transition: '0.3s',
            }}
        >
            <input {...getInputProps()} />
            <Box>
                <Typography variant="h6" color="textSecondary">
                    {isDragActive ? 'Drop files here...' : `Drag and drop file${multiple ? 's' : ''} here or click to select`}
                </Typography>
                <Typography variant="body2" color="textSecondary" sx={{ mt: 1 }}>
                    (Accepted files: .pdf, .jpg, .jpeg, .png)
                </Typography>
                {value && (
                    <Typography variant="body2" sx={{ mt: 2, color: 'success.main' }}>
                        {multiple
                            ? `${value.length} file(s) selected`
                            : `Selected file: ${value.name}`}
                    </Typography>
                )}
            </Box>
        </Paper>
    );
};

export default Dropzone;
