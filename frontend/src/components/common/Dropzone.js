import {Paper} from "@mui/material";
import {useDropzone} from "react-dropzone";
import Box from "@mui/material/Box";
import Typography from "@mui/material/Typography";

const FileDropzone = ({onDrop, multiple = false}) => {
    const {getRootProps, getInputProps, isDragActive} = useDropzone({
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
                    {isDragActive ? 'Upuść pliki tutaj...' : 'Przeciągnij i upuść pliki tutaj lub kliknij, aby wybrać'}
                </Typography>
                <Typography variant="body2" color="textSecondary" sx={{mt: 1}}>
                    (Akceptowane pliki: .pdf, .jpg, .jpeg, .png)
                </Typography>
            </Box>
        </Paper>
    );
};

export default FileDropzone;