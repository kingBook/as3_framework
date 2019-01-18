using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[Serializable]
public class Array<T> : IList<T>
{
    [SerializeField]
    private List<T> list;

#if UNITY_EDITOR
    [HideInInspector]
    public int listID=-1;
	[HideInInspector]
	public bool isEdit=false;
	[HideInInspector]
	public float curveRatio=0.1f;
#endif //end UNITY_EDITOR

    public Array()
    {
        list = new List<T>();
    }

    public Array(IEnumerable<T> collection)
    {
        list = new List<T>(collection);
    }

    public Array(int capacity)
    {
        list = new List<T>(capacity);
    }

    public T this[int index]
    {
        get
        {
            return list[index];
        }

        set
        {
            list[index] = value;
        }
    }

    public int Count
    {
        get
        {
            return list.Count;
        }
    }

    public bool IsReadOnly
    {
        get
        {
            return false;
        }
    }

    public void Add(T item)
    {
        list.Add(item);
    }

    public void Clear()
    {
        list.Clear();
    }

    public bool Contains(T item)
    {
        return list.Contains(item);
    }

    public void CopyTo(T[] array, int arrayIndex)
    {
        list.CopyTo(array, arrayIndex);
    }

    public IEnumerator<T> GetEnumerator()
    {
        return list.GetEnumerator();
    }

    public int IndexOf(T item)
    {
        return list.IndexOf(item);
    }

    public void Insert(int index, T item)
    {
        list.Insert(index, item);
    }

    public bool Remove(T item)
    {
        return list.Remove(item);
    }

    public void RemoveAt(int index)
    {
        list.RemoveAt(index);
    }

    IEnumerator IEnumerable.GetEnumerator()
    {
        return list.GetEnumerator();
    }
}

#region 基础数据类型

[Serializable]
public class IntArray : Array<int>
{

}

[Serializable]
public class IntArray2D : Array<IntArray>
{

}

[Serializable]
public class IntArray3D : Array<IntArray2D>
{

}

[Serializable]
public class FloatArray : Array<float>
{

}

[Serializable]
public class FloatArray2D : Array<FloatArray>
{

}

[Serializable]
public class FloatArray3D : Array<FloatArray2D>
{

}

[Serializable]
public class StringArray : Array<string>
{

}

[Serializable]
public class StringArray2D : Array<StringArray>
{

}

[Serializable]
public class StringArray3D : Array<StringArray2D>
{

}

#endregion

#region Unity数据类型

[Serializable]
public class GameObjectArray : Array<GameObject>
{

}

[Serializable]
public class GameObjectArray2D : Array<GameObjectArray>
{

}

[Serializable]
public class GameObjectArray3D : Array<GameObjectArray2D>
{

}

[Serializable]
public class TransformArray : Array<Transform>
{

}

[Serializable]
public class TransformArray2D : Array<TransformArray>
{

}

[Serializable]
public class TransformArray3D : Array<TransformArray2D>
{

}

[Serializable]
public class Vector2Array : Array<Vector2>
{

}

[Serializable]
public class Vector2Array2D : Array<Vector2Array>
{

}

[Serializable]
public class Vector2Array3D : Array<Vector2Array2D>
{

}

[Serializable]
public class Vector3Array : Array<Vector3>
{

}

[Serializable]
public class Vector3Array2D : Array<Vector3Array>
{

}

[Serializable]
public class Vector3Array3D : Array<Vector3Array2D>
{

}

[Serializable]
public class Vector4Array : Array<Vector4>
{

}

[Serializable]
public class Vector4Array2D : Array<Vector4Array>
{

}

[Serializable]
public class Vector4Array3D : Array<Vector4Array2D>
{

}

[Serializable]
public class ColorArray : Array<Color>
{

}

[Serializable]
public class ColorArray2D : Array<ColorArray>
{

}

[Serializable]
public class ColorArray3D : Array<ColorArray2D>
{

}

#endregion