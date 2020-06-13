import { Component, createRef } from 'inferno';
import { createLogger } from '../logging';

const logger = createLogger('Map');

export class Map extends Component {
  constructor(props) {
    super(props);
    const {
      initial_focus_x,
      initial_focus_y,
      ...rest
    } = this.props;
    this.mapContainerRef = createRef();
    this.state = { focus_x: initial_focus_x, focus_y: initial_focus_y };
  }

  componentDidMount() {
    let map = this.mapContainerRef.current;
	  if (map) {
      // Do not question this. It just works.
      map.scrollLeft = this.state.focus_x * 12 - 300;
      if (this.state.focus_y >= 45) { map.scrollTop = 1000+this.state.focus_y; }
      else { map.scrollTop = 2000+this.state.focus_y; }
      this.state.focus_x = map.scrollLeft;
      this.state.focus_y = map.scrollTop;
      logger.warn(this.state.focus_x);
	    logger.warn(this.state.focus_y);
	  }
  }

  componentWillUnmount() {
    
  }
  
  mousedownHandler(e) {
    // This code is actual cancer, please fix -Kmc
    let curr_x = e.screenX;
    let curr_y = e.screenY;
    let mousemove = e => {
	  e.preventDefault();
      let map = this.mapContainerRef.current;
	  if (map) {
        this.state.focus_x -= (e.screenX - curr_x);
        this.state.focus_y -= (e.screenY - curr_y);
        map.scrollLeft = this.state.focus_x;
        map.scrollTop = this.state.focus_y;
	    this.state.focus_x = map.scrollLeft;
        this.state.focus_y = map.scrollTop;
        curr_x = e.screenX;
        curr_y = e.screenY;
        logger.warn(curr_x);
	    logger.warn(curr_y);
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
        id="mapContainer"
        style="transition: scrollLeft 1s, scrollTop 1s;"
        ref={this.mapContainerRef}
        onMousedown={this.mousedownHandler.bind(this)}
        unselectable="on" className="outerbg">
        <div unselectable="on" className="innerbg" id="mapDraggable" style="position:absolute;">
          {this.props.children}
        </div>
      </div> 
    );
  }
}