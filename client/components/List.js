import React, {Component} from 'react';
import { gql } from 'apollo-boost';
import { graphql } from 'react-apollo';

const getBooksQuery=gql`
 {
  books{
   name
   id
  }
 }
`

class List extends Component {
 render() {
   console.log(this.props);
  return (
   <div>
     <ul id="list">
       <li>Book name</li>
     </ul>
   </div>
  );
 }
}

export default graphql(getBooksQuery)(List);
