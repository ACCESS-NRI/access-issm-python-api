import numpy as np


def newforcing(t0, t1, deltaT, f0, f1, nodes):
    '''
    NEWFORCING - Build forcing that extends temporally from t0 to t1, and in magnitude from f0 to f1. Equal time
                    and magnitude spacing.

    Usage: forcing = newforcing(t0, t1, deltaT, f0, f1, nodes);
    
    Where:
        t0:t1: time interval.
        deltaT: time step
        f0:f1: magnitude interval.
        nodes: number of vertices where we have a temporal forcing

    Example:
        md.smb.mass_balance = newforcing(
            md.timestepping.start_time, 
            md.timestepping.final_time, 
            md.timestepping.time_step, 
            -1, 
            +2, 
            md.mesh.numberofvertices
            )
    '''
    
    #Number of time steps:
    nsteps = (t1 - t0) / deltaT + 1

    #delta forcing:
    deltaf = (f1 - f0) / (nsteps - 1)

    #creates times:
    times = np.arange(t0, t1 + deltaT, deltaT)  #Add deltaT to fix python / matlab discrepency

    #create forcing:
    forcing = np.arange(f0, f1 + deltaf, deltaf)  #Add deltaf to fix python / matlab discrepency

    #replicate for all nodes
    forcing = np.tile(forcing, (nodes + 1, 1))
    forcing[-1, :] = times
    return forcing
