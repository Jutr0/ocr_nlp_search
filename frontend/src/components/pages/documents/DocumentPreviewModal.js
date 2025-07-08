import Modal from "../../common/Modal";
import DocumentPreview from "./DocumentPreview";
import {Button} from "@mui/material";
import {buildActions} from "../../../utils/actionsBuilder";
import {useEffect, useState} from "react";

const DocumentPreviewModal = ({document, onClose, onApprove, onReject}) => {
    const [fullDocument, setFullDocument] = useState(document);
    const actions = buildActions("document");

    useEffect(() => {
        actions.getOne(document.id).then(setFullDocument)
    }, [])

    return <Modal
        open
        size="xl"
        title={`${document.file.filename} - View`}
        actions={<>
            <Button onClick={onClose} variant='outlined' color="secondary">Edit</Button>
            <Button variant='contained' color="success"
                    onClick={() => onApprove(document.id)}>Approve</Button>
            <Button variant='contained' color="error"
                    onClick={() => onReject(document.id)}>Reject</Button>
            <Button onClick={onClose} variant='outlined'>Close</Button>
        </>}>
        <DocumentPreview document={fullDocument}/>
    </Modal>

}

export default DocumentPreviewModal