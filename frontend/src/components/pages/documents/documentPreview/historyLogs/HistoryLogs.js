import HistoryLog from "./HistoryLog";
import React from "react";
import ExpandableView from "../../../../common/ExpandableView";

const MAX_PREVIEW_COUNT = 3

const HistoryLogs = ({historyLogs}) => {

    const expandable = historyLogs && historyLogs.length > MAX_PREVIEW_COUNT

    return <ExpandableView title="History" expandable={expandable}>
        {historyLogs && historyLogs.map(log => <HistoryLog historyLog={log}/>)}
    </ExpandableView>
}

export default HistoryLogs;