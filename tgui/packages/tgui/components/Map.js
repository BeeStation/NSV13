import { Component, createRef } from 'inferno';
import { createLogger } from '../logging';

const logger = createLogger('Map');

export class Map extends Component {
  constructor(props) {
    super(props);
    const {
      initial_focus_x,
      initial_focus_y,
      initial_scale_factor,
      grid,
      ...rest
    } = this.props;
    this.mapContainerRef = createRef();
    this.state = { focus_x: initial_focus_x, focus_y: initial_focus_y, grid: grid, scale_factor: initial_scale_factor };
  }

  componentDidMount() {
    let map = this.mapContainerRef.current;
    if (map) {
      // Do not question this. It just works.
      if (!this.state.grid) {
        map.scrollLeft = this.state.focus_x * this.state.scale_factor - 300;
        map.scrollTop = (100-this.state.focus_y) * this.state.scale_factor + 500;
      } else {
        map.scrollLeft = this.state.focus_x * this.state.scale_factor - 500;
        map.scrollTop = (100-this.state.focus_y) * this.state.scale_factor + 2500;
      }
      let updateState = (x, y) => {
        this.setState({
          focus_x: x,
          focus_y: y,
        });
      };
      updateState(map.scrollLeft, map.scrollTop);
    }
  }

  /*
		this.setState({
          focus_x: this.state.focus_x - (e.screenX - curr_x),
		  focus_y: this.state.focus_y - (e.screenX - curr_y)
		})
				this.setState({
          focus_x: map.scrollLeft,
		  focus_y: map.scrollTop
		})
  */
  mousedownHandler(e) {
    let curr_x = e.screenX;
    let curr_y = e.screenY;
    let updateState = (x, y) => {
      this.setState({
        focus_x: x,
        focus_y: y,
      });    
    };
	
    let mousemove = e => {
      e.preventDefault();
      let map = this.mapContainerRef.current;
      if (map) {
        let pre_x = this.state.focus_x-(e.screenX - curr_x);
        let pre_y = this.state.focus_y-(e.screenY - curr_y);
        updateState(pre_x, pre_y);
        map.scrollLeft = this.state.focus_x;
        map.scrollTop = this.state.focus_y;
        updateState(map.scrollLeft, map.scrollTop);
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
        id="mapContainer"
        ref={this.mapContainerRef}
        onMousedown={this.mousedownHandler.bind(this)}
        unselectable="on" className={this.state.grid ? "outerbgdradis" : "outerbg"}>
        <div unselectable="on" className={this.state.grid ? "innerbgdradis" : "innerbg"} id="mapDraggable">
          {this.props.children}
        </div>
      </div> 
    );
  }
}