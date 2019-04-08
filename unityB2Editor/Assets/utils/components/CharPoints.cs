using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class CharPoints : MonoBehaviour{
    [SerializeField]
    private string _name;
    [SerializeField]
    private List<Vector2Array> _paths=new List<Vector2Array>();
#if UNITY_EDITOR
    [HideInInspector]
	public Vector2 point=new Vector2();
#endif
    void Start(){
        
    }

    void Update(){
        
    }

    public List<Vector2Array> paths{
        get{return _paths;}
    }
}
