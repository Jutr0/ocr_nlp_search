import React, {useCallback} from 'react';
import FileDropzone from "../common/Dropzone";
import {save} from "../../utils/actionsBuilder";

const UploadPage = () => {

    const actions = {createDocument: document => save('/documents', 'POST', document)}


    const handleDrop = useCallback((files) => {
        console.log('Pliki wrzucone:', files);
        if (files.length === 0) return

        const formData = new FormData();
        formData.append('file', files[0]);
        actions.createDocument(formData);
    }, []);

    return (
        <div>
            <FileDropzone onDrop={handleDrop} accept="application/pdf"/>
        </div>
    );
};

export default UploadPage;
