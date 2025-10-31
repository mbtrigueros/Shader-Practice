using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class TargetPosition : MonoBehaviour
{
    [SerializeField] Transform target;
    [SerializeField] Material mat;

    // Update is called once per frame
    void Update()
    {
        if (target && mat)
        {
            mat.SetVector("_TargetPosition", target.position);
            Debug.Log("hola");
        }
    }
}
