import {useState} from "react";
//import Config from "./config.json";
//import env from "./.env";
//import {port} from './vars.js'; 
//import {} from './vars.js';
//import {API_URL} from './.env';
export const useTitle = ()=>{
    const [resp,setResp] = useState();
    //const port = Config.PORT;
    //const envPort = process.env.PORT;
    //let url = `http://${domain}:${port}/graphql`;
    //let url = `http://wp-db-js-wordpress-service.k8s-${ENVIRONMENT}.svc.cluster.local:8000/graphql`;
    //let url = `http://wordpress:80`;
    //let url = `http://localhost:8003/graphql`;
    let url = `${process.env.NEXT_PUBLIC_API_URL}`;
    const getResp = async()=>{
        const res= await fetch(url, {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({ query: `
            query MyQuery {
              posts {
                nodes {
                  title
                  uri
                }
              }
            }
            `
            }),
        })
            .then(res => res.json())
            .then(res => res.data);
        setResp(res)
    }
    return {resp,getResp,status:!!resp}
}
