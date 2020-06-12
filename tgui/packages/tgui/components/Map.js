import { Component, createRef } from 'inferno';

export class Map extends Component {
  constructor(props) {
    super(props);
	  const {
		initial_focus_x,
		initial_focus_y,
		...rest
	  } = props;
    this.mapContainerRef = createRef();
    this.state = { focus_x: initial_focus_x, focus_y: initial_focus_y };
  }

  componentDidMount() {

  }

  componentWillUnmount() {
    
  }
  
  mousedownHandler(e) {
    // This code is actual cancer, please fix -Kmc
    let curr_x = e.screenX;
    let curr_y = e.screenY;
    let mousemove = e => {
      let map = this.mapContainerRef.current;
	  if(map){
        this.state.focus_x += (e.screenX - curr_x);
        this.state_focus_y += (e.screenY - curr_y);
        map.scrollLeft = this.state.focus_x;
        map.scrollTop = this.state.focus_y;
	    this.state.focus_x = map.scrollLeft;
        this.state.focus_y = map.scrollTop;
        curr_x = e.screenX;
        curr_y = e.screenY;
	  }
    };
    let mouseup = e => {
      document.removeEventListener("mousemove", mousemove);
      document.removeEventListener("mouseup", mouseup);
    };
    document.addEventListener("mousemove", mousemove);
    document.addEventListener("mouseup", mouseup);
  }

  render() {
    return (
      <div
        ref={this.mapContainerRef}
        onMousedown={this.mousedownHandler.bind(this)}
        unselectable="on" className="outerbg">
        <div unselectable="on" className="innerbg">
          {this.props.children}
        </div>
      </div> 
    );
  }
}