import { useState, useEffect } from "react";
import Head from "next/head";
import Footer from "../components/Footer";
import PostCard from "../components/PostCard";
import { getAllPosts } from "../lib/test-data";
import { useTitle } from "../hooks/useTitle";

//const json2html = require('node-json2html');

export default function Home({ posts }) {
  //   const res=fetch('https://swapi-graphql.netlify.app/.netlify/functions/index', {
  //         method: 'POST',
  //         headers: { 'Content-Type': 'application/json' },
  //         body: JSON.stringify({ query: `{
  //   allFilms {
  //     films {
  //       title
  //     }
  //   }
  // }`
  // }),
  // })
  //         .then(res => res.json())
  // .then(res => console.log(res.data));
  const { resp, getResp, status } = useTitle();

  //   let template = {'<>':'div','html':'${title} ${uri}'};
  // let htmldata=res.data;

  // let htmlfromjson=json2html.render(htmldata,template);

  /*const [resp,setResp] = useState()
useEffect(()=>{
setResp( fetch('http://localhost:8000/graphql', {
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
.then(res => res.data))
},[])
console.log(resp);*/
  useEffect(() => {
    getResp();
  }, []);
  console.log(resp?.posts?.nodes);
  return (
    <div className="container">
      {/* {status ? (
        resp.allFilms.films.map((film) => <div>{film.title}</div>)
      ) : (
        <div>Loading</div>
      )} */
      status ? (
        resp.posts.nodes.map((node,index) => <div key={index}>{node.title}</div>)
 ) : (
   <div>Loading</div>
 )}

      <Head>
        <title>Headless WP Next Starter</title>
        <link rel="icon" href="favicon.ico"></link>
      </Head>

      <main>
        <h1 className="title">Headless WordPress Next.js Starter</h1>

        {/* <div>
          {
            htmlfromjson
          }
        </div> */}

        <p className="description">
          Get started by editing <code>pages/index.js</code>
        </p>

        <div className="grid">
          {posts.map((post) => {
            return <PostCard key={post.uri} post={post}></PostCard>;
          })}
        </div>
      </main>

      <Footer></Footer>
    </div>
  );
}

export async function getStaticProps() {
  const response = await getAllPosts();
  const posts = response?.data?.posts?.nodes;
  return {
    props: {
      posts,
    },
  };
}
