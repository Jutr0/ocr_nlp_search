import React from "react";
import ExpandableView from "../../../common/ExpandableView";

const DocumentOcrOutput = ({text}) => {

    return <ExpandableView title="OCR Output" previewHeight='3.2em'>
        <pre>
            {text}
        </pre>
    </ExpandableView>
}

export default DocumentOcrOutput;