import React from 'react';
import ReactDOM from 'react-dom';
import { findDOMNode } from 'react-dom';

export function Bad({ html }: { html: string }) {
  return <div dangerouslySetInnerHTML={{ __html: html }} />;
}

export class Legacy extends React.Component {
  componentDidMount() {
    findDOMNode(this);
  }
  render() {
    return <div />;
  }
}

ReactDOM.render(<Bad html="<b>x</b>" />, document.getElementById('root'));
