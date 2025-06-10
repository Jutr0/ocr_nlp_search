import axios from "axios";

export const get = (url, params) => {
    const config = {
        url,
        params
    };
    return axios.request(config).then(
        result => result.data
    );
};

export const save = (url, method, data) => {
    const config = {
        url,
        data,
        method
    };
    return axios.request(config).then(
        result => result.data
    )
};

export const remove = (url) => {
    const config = {
        url,
        method: "DELETE"
    }
    return axios.request(config).then(result =>result.data)
}

export const buildActions = (resourceName, url) => {
    let apiUrl = url || resourceName + "s"
    const getAll = () => {
        return get(apiUrl)
    }

    const getOne = (id) => {
        return get(`${apiUrl}/${id}`)
    }

    const saveResource = (resource) => {
        let method = "POST"
        if (resource.id) {
            apiUrl += `/${resource.id}`
            method = "PUT"
        }
        return save(apiUrl, method, {[resourceName]: resource})
    }
    const deleteResource = (resource) => {
        apiUrl += `/${resource.id}`
        return remove(apiUrl)
    }

    return {getAll, getOne, save: saveResource, delete: deleteResource}
}
