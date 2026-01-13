using System;
using System.Collections.Generic;
using System.Globalization;
using System.Linq;
using System.Windows;
using System.Windows.Controls;
using System.Windows.Input;
using System.Windows.Media;
using netDxf;
using netDxf.Entities;
using Point = System.Windows.Point;
using Brushes = System.Windows.Media.Brushes;
using Pen = System.Windows.Media.Pen;
using Size = System.Windows.Size;

namespace OmsDesktop.Controls;

public class DxfCanvas : FrameworkElement
{
    private DxfDocument? _document;
    private Matrix _transform = Matrix.Identity;
    private Point _lastMousePos;
    private bool _isDragging;
    private double _scale = 1.0;
    private Vector _offset = new Vector(0, 0);

    public DxfDocument? Document
    {
        get => _document;
        set
        {
            _document = value;
            if (_document != null)
            {
                FitToView();
            }
            InvalidateVisual();
        }
    }

    public DxfCanvas()
    {
        this.ClipToBounds = true;
        // this.Background = Brushes.White; // Removed as FrameworkElement doesn't have Background
    }

    protected override void OnMouseWheel(MouseWheelEventArgs e)
    {
        var pos = e.GetPosition(this);
        double zoom = e.Delta > 0 ? 1.1 : 0.9;
        
        // Scale around mouse position
        _scale *= zoom;
        
        // Adjust offset to keep mouse position stable
        // world = (screen - offset) / scale
        // new_offset = screen - world * new_scale
        //            = screen - ((screen - old_offset) / old_scale) * new_scale
        
        _offset = (Vector)pos - ((Vector)pos - _offset) * zoom;

        InvalidateVisual();
    }

    protected override void OnMouseDown(MouseButtonEventArgs e)
    {
        if (e.ChangedButton == MouseButton.Left)
        {
            _isDragging = true;
            _lastMousePos = e.GetPosition(this);
            this.CaptureMouse();
        }
    }

    protected override void OnMouseMove(System.Windows.Input.MouseEventArgs e)
    {
        if (_isDragging)
        {
            var pos = e.GetPosition(this);
            var delta = pos - _lastMousePos;
            _offset += delta;
            _lastMousePos = pos;
            InvalidateVisual();
        }
    }

    protected override void OnMouseUp(MouseButtonEventArgs e)
    {
        if (e.ChangedButton == MouseButton.Left)
        {
            _isDragging = false;
            this.ReleaseMouseCapture();
        }
    }

    private void FitToView()
    {
        if (_document == null) return;

        // Calculate bounds (approximate)
        // netDxf doesn't always have up-to-date bounds, might need to calculate
        // But let's try assuming 0,0 center if not available or iterating entities.
        
        double minX = double.MaxValue, minY = double.MaxValue;
        double maxX = double.MinValue, maxY = double.MinValue;

        // Helper to update bounds
        void UpdateBounds(Vector3 v)
        {
            if (v.X < minX) minX = v.X;
            if (v.Y < minY) minY = v.Y;
            if (v.X > maxX) maxX = v.X;
            if (v.Y > maxY) maxY = v.Y;
        }

        // Iterate common entities
        foreach (var line in _document.Entities.Lines)
        {
            UpdateBounds(line.StartPoint);
            UpdateBounds(line.EndPoint);
        }
        foreach (var circle in _document.Entities.Circles)
        {
            UpdateBounds(circle.Center + new Vector3(circle.Radius, circle.Radius, 0));
            UpdateBounds(circle.Center - new Vector3(circle.Radius, circle.Radius, 0));
        }
        // ... Add more as needed. For now, Lines/Circles are main checks.
        // If empty, default.
        if (minX == double.MaxValue)
        {
            minX = -100; maxX = 100; minY = -100; maxY = 100;
        }

        double width = maxX - minX;
        double height = maxY - minY;
        
        if (width == 0) width = 100;
        if (height == 0) height = 100;

        // Margin
        width *= 1.1;
        height *= 1.1;
        
        double viewWidth = this.ActualWidth > 0 ? this.ActualWidth : 800;
        double viewHeight = this.ActualHeight > 0 ? this.ActualHeight : 600;

        double scaleX = viewWidth / width;
        double scaleY = viewHeight / height;
        
        _scale = Math.Min(scaleX, scaleY);
        
        // Center
        double midX = (minX + maxX) / 2;
        double midY = (minY + maxY) / 2;
        
        // Offset to center
        // ScreenCenter = (WorldPoint * Scale) + Offset
        // Offset = ScreenCenter - WorldPoint * Scale
        
        _offset = new Vector(viewWidth / 2, viewHeight / 2) - new Vector(midX, midY) * _scale;
        
        // Flip Y (DXF is Y up, Screen is Y down)
        // Actually, we usually handle this by scaling Y by -1.
        // Let's do that in rendering transform.
        // If we flip Y, we need to adjust offset calculation.
        // Let's keep it simple: Logic Y = -World Y.
    }

    protected override void OnRender(DrawingContext dc)
    {
        // Background
        dc.DrawRectangle(Brushes.White, null, new Rect(0, 0, ActualWidth, ActualHeight));

        if (_document == null) return;

        // Setup transform
        // We want Y up. So we scale Y by -1.
        // ScreenY = (WorldY * -1) * Scale + OffsetY
        
        // Let's use a transform group
        // 1. Scale(1, -1) to flip Y
        // 2. Translate(Offset)
        // 3. Scale(Zoom) - wait, _scale includes zoom.
        
        // Let's manually transform points for simplicity in code, 
        // or use PushTransform.
        
        // Transformation:
        // ScreenX = X * _scale + _offset.X
        // ScreenY = -Y * _scale + _offset.Y (because DXF Y is up, Screen Y is down)
        
        Point WorldToScreen(Vector3 v)
        {
            return new Point(v.X * _scale + _offset.X, -v.Y * _scale + _offset.Y);
        }
        
        // Optimization: Freeze pens
        var pen = new Pen(Brushes.Black, 1);
        pen.Freeze();

        // Use StreamGeometry for lines/polylines
        var geometry = new StreamGeometry();
        using (var ctx = geometry.Open())
        {
            foreach (var line in _document.Entities.Lines)
            {
                ctx.BeginFigure(WorldToScreen(line.StartPoint), false, false);
                ctx.LineTo(WorldToScreen(line.EndPoint), true, false);
            }
            
            foreach (var poly in _document.Entities.Polylines2D)
            {
                if (poly.Vertexes.Count < 2) continue;
                // Polyline2DVertex.Position is Vector2
                var p0 = poly.Vertexes[0].Position;
                var start = WorldToScreen(new Vector3(p0.X, p0.Y, 0));
                ctx.BeginFigure(start, false, poly.IsClosed);
                for (int i = 1; i < poly.Vertexes.Count; i++)
                {
                    var pi = poly.Vertexes[i].Position;
                    ctx.LineTo(WorldToScreen(new Vector3(pi.X, pi.Y, 0)), true, false);
                }
            }
            
             foreach (var poly in _document.Entities.Polylines3D)
            {
                if (poly.Vertexes.Count < 2) continue;
                // Polyline3DVertex might be Vector3 or have Position?
                // Error said Vector3 doesn't have Position, so it IS Vector3.
                var start = WorldToScreen(poly.Vertexes[0]);
                ctx.BeginFigure(start, false, poly.IsClosed);
                for (int i = 1; i < poly.Vertexes.Count; i++)
                {
                    ctx.LineTo(WorldToScreen(poly.Vertexes[i]), true, false);
                }
            }

            // LwPolyline (Commented out if causing issues or use Polylines)
            /*
            foreach (var poly in _document.Entities.LwPolylines)
            {
                 if (poly.Vertexes.Count < 2) continue;
                 var start = WorldToScreen(new Vector3(poly.Vertexes[0].Position.X, poly.Vertexes[0].Position.Y, 0));
                 ctx.BeginFigure(start, false, poly.IsClosed);
                 for(int i=1; i<poly.Vertexes.Count; i++)
                 {
                     ctx.LineTo(WorldToScreen(new Vector3(poly.Vertexes[i].Position.X, poly.Vertexes[i].Position.Y, 0)), true, false);
                 }
            }
            */
        }
        geometry.Freeze();
        dc.DrawGeometry(null, pen, geometry);

        // Draw Circles/Arcs (Geometry is better than DrawEllipse for scaling)
        // We can add them to StreamGeometry if we approximate, 
        // or use DrawGeometry with EllipseGeometry.
        
        foreach (var circle in _document.Entities.Circles)
        {
            double r = circle.Radius * _scale;
            Point center = WorldToScreen(circle.Center);
            dc.DrawEllipse(null, pen, center, r, r);
        }

        foreach (var arc in _document.Entities.Arcs)
        {
            // Drawing arcs is complex in WPF StreamGeometry (requires start/end point and size)
            // Or use path geometry.
            // For now, let's approximate with lines if needed, or use a helper.
            // Actually, StreamGeometryContext.ArcTo is available.
            // We need StartPoint, Point, Size, etc.
            
            // Calculate start and end points
            double startAngle = arc.StartAngle * Math.PI / 180.0;
            double endAngle = arc.EndAngle * Math.PI / 180.0;
            
            double r = arc.Radius;
            double sx = arc.Center.X + r * Math.Cos(startAngle);
            double sy = arc.Center.Y + r * Math.Sin(startAngle);
            
            double ex = arc.Center.X + r * Math.Cos(endAngle);
            double ey = arc.Center.Y + r * Math.Sin(endAngle);
            
            Point pStart = WorldToScreen(new Vector3(sx, sy, 0));
            Point pEnd = WorldToScreen(new Vector3(ex, ey, 0));
            
            Size size = new Size(r * _scale, r * _scale);
            
            bool isLarge = (arc.EndAngle - arc.StartAngle) > 180;
            if (arc.EndAngle < arc.StartAngle) isLarge = !isLarge; // Handle wrap around?
            // netDxf angles are 0-360 usually.
            
            // Sweep direction: DXF is CCW.
            // Screen Y is flipped, so visual arc is CW?
            // ScreenX = X, ScreenY = -Y.
            // CCW in world (X -> Y) becomes CW in screen (X -> -Y).
            
            // Let's try drawing it.
            var arcGeo = new StreamGeometry();
            using (var ctx = arcGeo.Open())
            {
                ctx.BeginFigure(pStart, false, false);
                ctx.ArcTo(pEnd, size, 0, isLarge, SweepDirection.Clockwise, true, false);
            }
            arcGeo.Freeze();
            dc.DrawGeometry(null, pen, arcGeo);
        }
        
        // Texts
        foreach (var text in _document.Entities.Texts)
        {
             Point p = WorldToScreen(text.Position);
             // Basic text rendering
             FormattedText ft = new FormattedText(
                 text.Value,
                 CultureInfo.CurrentCulture,
                 System.Windows.FlowDirection.LeftToRight,
                 new Typeface("Arial"),
                 text.Height * _scale,
                 Brushes.Blue,
                 VisualTreeHelper.GetDpi(this).PixelsPerDip);
             
             // Handle rotation if needed
             if (text.Rotation != 0)
             {
                 dc.PushTransform(new RotateTransform(-text.Rotation, p.X, p.Y)); // -Rotation because Y flip?
                 dc.DrawText(ft, new Point(p.X, p.Y - ft.Height)); // Adjust origin to baseline approx
                 dc.Pop();
             }
             else
             {
                 dc.DrawText(ft, new Point(p.X, p.Y - ft.Height));
             }
        }
        
        // MTexts (Similar to Text but with box)
        foreach (var text in _document.Entities.MTexts)
        {
             Point p = WorldToScreen(text.Position);
             FormattedText ft = new FormattedText(
                 text.Value, // This might contain formatting codes like \P, need to strip
                 CultureInfo.CurrentCulture,
                 System.Windows.FlowDirection.LeftToRight,
                 new Typeface("Arial"),
                 text.Height * _scale,
                 Brushes.Blue,
                 VisualTreeHelper.GetDpi(this).PixelsPerDip);
                 
             dc.DrawText(ft, new Point(p.X, p.Y));
        }
    }
}
