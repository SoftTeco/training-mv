import {useState} from "react";

export const useTitle = ()=>{
    const [resp,setResp] = useState();
    //let url = `http://localhost:${process.env.NEXT_PUBLIC_PORT}/graphql`;
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
