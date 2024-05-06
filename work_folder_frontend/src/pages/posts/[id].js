import {useRouter} from "next/router";
import getConfig from "next/config";

function Post({post}) {
  const router = useRouter();

  // If the page is not yet generated, this will be displayed
  // initially until getStaticProps() finishes running
  if (router.isFallback) {
    return <div>Loading...</div>;
  }

  return (
    <h1>
      {post.id} - {post.title}
    </h1>
  );
}

// This function gets called at build time
export async function getStaticPaths() {
  return {
    // Only `/posts/1` and `/posts/2` are generated at build time
    paths: [],
    // Enable statically generating additional pages
    // For example: `/posts/3`
    fallback: true,
  };
}

// This also gets called at build time
export async function getStaticProps({params}) {
  const {serverRuntimeConfig} = getConfig();

  const res = await fetch(`${serverRuntimeConfig.apiUrl}/posts/${params.id}`);
  const post = await res.json();
  console.log(`Requested post with id: ${params.id}`);
  // Pass post data to the page via props
  return {
    props: {post},
    // Re-generate the post at most once per second
    // if a request comes in
    revalidate: 60,
  };
}

export default Post;
